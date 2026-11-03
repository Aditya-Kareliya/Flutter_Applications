import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../modules/admin_module/dashboard/data/admin_data_store.dart';

/// Service responsible for real-time email dispatch for devotee inquiries and administrative responses.
/// Uses secure HTTP form delivery gateways (FormSubmit AJAX) and Firestore mail trigger integration
/// to guarantee actual inbox delivery without exposing private SMTP credentials.
class EmailNotificationService {
  EmailNotificationService._();
  static final EmailNotificationService instance = EmailNotificationService._();

  /// Resolves the hosted brand logo HTTPS URL for public email rendering.
  String _getLogoUrl() {
    final settingsLogo = AdminDataStore.instance.settings.logoImageUrl.trim();
    if (settingsLogo.startsWith('http://') || settingsLogo.startsWith('https://')) {
      return settingsLogo;
    }
    // High-resolution public CDN/raw GitHub asset accessible worldwide by Gmail, Apple Mail, Outlook, etc.
    return 'https://raw.githubusercontent.com/Aditya-Kareliya/Flutter_Applications/pavan_putra_garbi_mandal/assets/images/pavan_putra_logo.png';
  }

  String _getMandalNameGu() {
    final val = AdminDataStore.instance.settings.mandalNameGu.trim();
    return val.isNotEmpty ? val : 'શ્રી પવન પુત્ર ગરબી મંડળ - રાજકોટ';
  }

  String _getMandalNameEn() {
    final val = AdminDataStore.instance.settings.mandalNameEn.trim();
    return val.isNotEmpty ? val : 'SHREE PAVAN PUTRA GARBI MANDAL TRUST';
  }

  String _getContactPhone() {
    final val = AdminDataStore.instance.settings.contactPhone.trim();
    return val.isNotEmpty ? val : '';
  }

  String _getVenueAddress() {
    final val = AdminDataStore.instance.settings.address.trim();
    return val.isNotEmpty ? val : 'પવનપુત્ર ચોક, શેરી નં. ૩, માવડી મેઈન રોડ, રાજકોટ - ૩૬૦૦૦૪, ગુજરાત';
  }

  String _getAartiSchedule() {
    final val = AdminDataStore.instance.settings.dailyAartiTime.trim();
    return val.isNotEmpty ? val : 'સંધ્યા આરતી ૭:૩૦ કલાકે • મહા આરતી ૧૧:૪૫ કલાકે (7:30 PM & 11:45 PM Daily)';
  }

  /// Sends a real-time notification to all active administrative notification emails.
  Future<bool> sendEnquiryNotification({
    required AdminEnquiry enquiry,
    required List<AdminNotificationEmail> recipients,
    String? fallbackEmail,
  }) async {
    final activeRecipients = recipients.where((r) => r.isEnabled && r.email.trim().isNotEmpty).toList();

    // If no recipients configured, use fallback or default mandal email
    final targetEmails = activeRecipients.isNotEmpty
        ? activeRecipients.map((r) => r.email.trim()).toSet().toList()
        : [
            if (fallbackEmail != null && fallbackEmail.trim().isNotEmpty)
              fallbackEmail.trim()
            else
              'pavanputragarbi@gmail.com',
          ];

    bool anySuccess = false;

    for (final email in targetEmails) {
      final recipientObj = activeRecipients.where((r) => r.email.trim() == email).firstOrNull;
      final recipientName = recipientObj?.recipientName ?? 'Administrator';

      try {
        final success = await _dispatchEmailViaGateway(
          toEmail: email,
          subject: '[pavanputragarbi mandal] New Devotee Inquiry: ${enquiry.name}',
          fields: {
            'Mandal': 'pavanputragarbi mandal',
            'Devotee Name': enquiry.name,
            'Contact Phone': enquiry.phone.isNotEmpty ? enquiry.phone : 'Not provided',
            'Email Address': enquiry.email.isNotEmpty ? enquiry.email : 'Not provided',
            'Submission Date': enquiry.date,
            'Inquiry Message': enquiry.message,
            'Target Officer': recipientName,
          },
          replyTo: enquiry.email.isNotEmpty ? enquiry.email : null,
        );

        if (success) anySuccess = true;
      } catch (e) {
        debugPrint('Email delivery error for $email: $e');
      }

      // Record to Firestore `mail` collection (standard for Firebase Trigger Email extension)
      try {
        if (FirebaseFirestore.instance.app.options.projectId.isNotEmpty) {
          await FirebaseFirestore.instance.collection('mail').add({
            'to': [email],
            'message': {
              'subject': '[pavanputragarbi mandal] New Devotee Inquiry: ${enquiry.name}',
              'text': _buildPlainTextNotification(enquiry: enquiry, recipientEmail: email),
              'html': _buildHtmlNotification(
                enquiry: enquiry,
                recipientEmail: email,
                recipientName: recipientName,
              ),
            },
            'created_at': FieldValue.serverTimestamp(),
          });
        }
      } catch (e) {
        debugPrint('Firestore mail collection write notice: $e');
      }
    }

    return anySuccess;
  }

  /// Sends a live test email to verify that an administrative notification address is actively receiving mail.
  Future<bool> sendTestEmail(AdminNotificationEmail recipient) async {
    final email = recipient.email.trim();
    if (email.isEmpty) return false;

    final now = DateTime.now();
    final timestampStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    try {
      final success = await _dispatchEmailViaGateway(
        toEmail: email,
        subject: '[pavanputragarbi mandal] Admin Notification System Active',
        fields: {
          'Mandal': 'pavanputragarbi mandal',
          'Officer Name': recipient.recipientName,
          'Department': recipient.department,
          'Verified Email': email,
          'Verified Time': timestampStr,
          'Status': 'Active & Operational',
        },
      );

      // Also record in Firestore
      try {
        await FirebaseFirestore.instance.collection('mail').add({
          'to': [email],
          'message': {
            'subject': '[pavanputragarbi mandal] Admin Notification System Active',
            'html': _buildTestHtml(recipient: recipient, timestamp: timestampStr),
          },
          'created_at': FieldValue.serverTimestamp(),
        });
      } catch (_) {}

      return success;
    } catch (e) {
      debugPrint('Test email error for $email: $e');
      return false;
    }
  }

  /// Sends a Forgot Password recovery email matching the MedSaral-style card layout.
  Future<bool> sendForgotPasswordEmail({
    required String email,
    String? resetLink,
  }) async {
    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty) return false;

    final link = (resetLink != null && resetLink.isNotEmpty)
        ? resetLink
        : 'https://pavanputragarbi.firebaseapp.com/__/auth/action?mode=resetPassword';

    try {
      final success = await _dispatchEmailViaGateway(
        toEmail: cleanEmail,
        subject: '[pavanputragarbi mandal] Forgot Password Recovery',
        fields: {
          'Mandal': 'pavanputragarbi mandal',
          'Action': 'Password Reset Request',
          'Registered Email': cleanEmail,
          'Reset Link': link,
          'Security Notice': 'If you did not request a password reset, you can safely ignore this email. Your password will remain unchanged.',
        },
      );

      // Record in Firestore `mail` collection
      try {
        await FirebaseFirestore.instance.collection('mail').add({
          'to': [cleanEmail],
          'message': {
            'subject': '[pavanputragarbi mandal] Forgot Password Recovery',
            'html': _buildForgotPasswordHtml(email: cleanEmail, resetLink: link),
          },
          'created_at': FieldValue.serverTimestamp(),
        });
      } catch (_) {}

      return success;
    } catch (e) {
      debugPrint('Forgot password email dispatch error: $e');
      return false;
    }
  }

  /// Sends an actual email response from the Mandal administration directly to the devotee's email address.
  Future<bool> sendResponseEmail({
    required AdminEnquiry enquiry,
    required String replySubject,
    required String replyMessage,
    required String senderName,
    required String senderEmail,
  }) async {
    final devoteeEmail = enquiry.email.trim();
    if (devoteeEmail.isEmpty) return false;

    try {
      final success = await _dispatchEmailViaGateway(
        toEmail: devoteeEmail,
        subject: replySubject.isNotEmpty
            ? replySubject
            : 'Pranam ${enquiry.name} ji — Response from ${_getMandalNameGu()}',
        fields: {
          '🏛️ Mandal / સંસ્થા': '${_getMandalNameGu()} (${_getMandalNameEn()})',
          '🙏 Sacred Invocation': '|| શ્રી ગણેશાય નમઃ || || જય માતાજી || || જાગતી જોગમાયા ||',
          '👤 Devotee Name (ભાવિકનું નામ)': enquiry.name,
          '💬 Mandal Response / મંડળનો પ્રત્યુત્તર': replyMessage,
          '👤 Responding Officer / ઉત્તર આપનાર': senderName,
          '✉️ Mandal Official Email': senderEmail,
          '📝 Original Devotee Message': enquiry.message,
          '📍 Mandal Venue / સરનામું': _getVenueAddress(),
          '⏰ Aarti Timings / આરતી સમય': _getAartiSchedule(),
          '📞 Helpline / હેલ્પલાઇન': _getContactPhone(),
        },
        replyTo: senderEmail,
      );

      // Record to Firestore
      try {
        await FirebaseFirestore.instance.collection('mail').add({
          'to': [devoteeEmail],
          'message': {
            'subject': replySubject,
            'html': _buildResponseHtml(
              enquiry: enquiry,
              replyMessage: replyMessage,
              senderName: senderName,
              senderEmail: senderEmail,
            ),
          },
          'created_at': FieldValue.serverTimestamp(),
        });
      } catch (_) {}

      return success;
    } catch (e) {
      debugPrint('Devotee response email dispatch error: $e');
      return false;
    }
  }

  // --- HTTP Gateway Helper (FormSubmit AJAX API) ---
  Future<bool> _dispatchEmailViaGateway({
    required String toEmail,
    required String subject,
    required Map<String, String> fields,
    String? replyTo,
  }) async {
    final cleanEmail = toEmail.trim();
    if (cleanEmail.isEmpty) return false;

    final url = Uri.parse('https://formsubmit.co/ajax/$cleanEmail');

    final payload = <String, dynamic>{
      ...fields,
      '_subject': subject,
      '_template': 'table',
      '_captcha': 'false',
    };

    if (replyTo != null && replyTo.trim().isNotEmpty) {
      payload['_replyto'] = replyTo.trim();
    }

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(payload),
    ).timeout(const Duration(seconds: 12));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    } else {
      debugPrint('FormSubmit status: ${response.statusCode} body: ${response.body}');
      return false;
    }
  }

  // --- HTML / Plain Text Email Templates matching Cultural Heritage Theme ---
  String _buildPlainTextNotification({required AdminEnquiry enquiry, required String recipientEmail}) {
    return '''
|| શ્રી ગણેશાય નમઃ || || ૐ નમઃ શિવાય || || જય માતાજી ||
${_getMandalNameGu()}
${_getMandalNameEn()} — RAJKOT

============================================================
NEW DEVOTEE INQUIRY / MESSAGE (નવો ભાવિક સંદેશ)
============================================================

Devotee Name: ${enquiry.name}
Phone: ${enquiry.phone.isNotEmpty ? enquiry.phone : "Not provided"}
Email: ${enquiry.email.isNotEmpty ? enquiry.email : "Not provided"}
Date: ${enquiry.date}
Target Officer Inbox: $recipientEmail

INQUIRY MESSAGE / PRAYER REQUEST:
${enquiry.message}

------------------------------------------------------------
Mandal Venue: ${_getVenueAddress()}
Daily Aarti: ${_getAartiSchedule()}
Portal Link: https://pavanputragarbi.web.app/#/admin
|| જાગતી જોગમાયા || || જય માતાજી ||
''';
  }

  String _buildHtmlNotification({required AdminEnquiry enquiry, required String recipientEmail, String? recipientName}) {
    final logoUrl = _getLogoUrl();
    final mandalGu = _getMandalNameGu();
    final mandalEn = _getMandalNameEn();
    final address = _getVenueAddress();
    final phone = _getContactPhone();
    final aarti = _getAartiSchedule();

    return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>New Devotee Inquiry Received — $mandalEn</title>
</head>
<body style="margin:0;padding:0;background-color:#f4f7f6;">
<table width="100%" border="0" cellpadding="0" cellspacing="0" style="background-color:#f4f7f6; padding:40px 15px; font-family: Arial, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;">
    <tbody>
        <tr>
            <td align="center">
                <!-- Main Content Container -->
                <table width="100%" border="0" cellpadding="0" cellspacing="0" style="max-width:600px;
                              background-color:#ffffff;
                              border-radius:12px;
                              overflow:hidden;
                              box-shadow:0 4px 15px rgba(0,0,0,0.05);
                              border:1px solid #e2e8f0;">
                    <tbody>
                        <!-- Header Section -->
                        <tr>
                            <td align="center" style="padding:40px 30px 20px 30px;">
                                <!-- Logo -->
                                <img src="$logoUrl" alt="Mandal Logo" width="120" height="120" style="display:block;
                                            border:0;
                                            margin:0 auto 25px auto;
                                            border-radius:50%;
                                            object-fit:cover;
                                            border:2px solid #C5A059;
                                            background-color:#ffffff;">

                                <h1 style="margin:0;
                                           color:#0a1332;
                                           font-size:24px;
                                           font-weight:700;
                                           margin-bottom:8px;">
                                    New Devotee Inquiry Received
                                </h1>

                                <div style="color:#C5A059;
                                            font-size:14px;
                                            font-weight:bold;
                                            margin-bottom:16px;">
                                    $mandalGu
                                </div>

                                <p style="margin:0 auto;
                                          color:#5a667b;
                                          font-size:15px;
                                          line-height:1.6;
                                          max-width:480px;
                                          text-align:center;">
                                    A new devotee inquiry has been submitted through the public website. Please review the details below.
                                </p>

                                <!-- Primary Button -->
                                ${enquiry.email.isNotEmpty ? '''
                                <table border="0" cellpadding="0" cellspacing="0" style="margin-top:28px;">
                                    <tbody>
                                        <tr>
                                            <td align="center" bgcolor="#4A000B" style="border-radius:8px;">
                                                <a href="mailto:${enquiry.email}?subject=Pranam ${enquiry.name} ji — $mandalGu" target="_blank" rel="noopener noreferrer" style="display:inline-block;
                                                          padding:14px 32px;
                                                          color:#ffffff;
                                                          text-decoration:none;
                                                          font-size:15px;
                                                          font-weight:bold;
                                                          border-radius:8px;
                                                          background-color:#4A000B;">
                                                    ✉️ Reply to Devotee
                                                </a>
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                                ''' : ''}

                            </td>
                        </tr>

                        <!-- Devotee Details Summary Card -->
                        <tr>
                            <td style="padding:10px 30px 20px 30px;">
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" style="background-color:#f8fafc;
                                              border:1px solid #e2e8f0;
                                              border-radius:8px;">
                                    <tbody>
                                        <tr>
                                            <td style="padding:20px 24px; font-size:14px; line-height:1.7;">
                                                <div style="margin-bottom:10px;">
                                                    <strong style="color:#334155;">Devotee Name:</strong>
                                                    <span style="color:#0f172a; font-weight:bold; margin-left:8px;">${enquiry.name}</span>
                                                </div>
                                                <div style="margin-bottom:10px;">
                                                    <strong style="color:#334155;">Contact Phone:</strong>
                                                    <span style="margin-left:8px;">${enquiry.phone.isNotEmpty ? '<a href="tel:${enquiry.phone}" style="color:#1a49ba; text-decoration:none; font-weight:bold;">${enquiry.phone}</a>' : '<span style="color:#94a3b8;">Not provided</span>'}</span>
                                                </div>
                                                <div style="margin-bottom:10px;">
                                                    <strong style="color:#334155;">Email Address:</strong>
                                                    <span style="margin-left:8px;">${enquiry.email.isNotEmpty ? '<a href="mailto:${enquiry.email}" style="color:#1a49ba; text-decoration:none; font-weight:bold;">${enquiry.email}</a>' : '<span style="color:#94a3b8;">Not provided</span>'}</span>
                                                </div>
                                                <div style="margin-bottom:10px;">
                                                    <strong style="color:#334155;">Submission Date:</strong>
                                                    <span style="color:#0f172a; margin-left:8px;">${enquiry.date}</span>
                                                </div>
                                                <div>
                                                    <strong style="color:#334155;">Target Officer:</strong>
                                                    <span style="color:#64748b; margin-left:8px;">$recipientEmail</span>
                                                </div>
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </td>
                        </tr>

                        <!-- Message Box -->
                        <tr>
                            <td style="padding:0 30px 24px 30px;">
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" style="background-color:#f8fafc;
                                              border-left:4px solid #C5A059;
                                              border-radius:8px;
                                              border-top:1px solid #e2e8f0;
                                              border-right:1px solid #e2e8f0;
                                              border-bottom:1px solid #e2e8f0;">
                                    <tbody>
                                        <tr>
                                            <td style="padding:18px 20px;
                                                       font-size:13.5px;
                                                       line-height:1.6;
                                                       color:#475569;">
                                                <strong style="color:#0f172a; font-size:14px;">
                                                    📝 Devotee Message / Prayer Request
                                                </strong>
                                                <br><br>
                                                ${enquiry.message}
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </td>
                        </tr>

                        <!-- Action Button (Second) -->
                        <tr>
                            <td align="center" style="padding:0 30px 34px 30px;">
                                ${enquiry.phone.isNotEmpty ? '''
                                <a href="tel:${enquiry.phone}" target="_blank" rel="noopener noreferrer" style="display:inline-block;
                                          padding:12px 28px;
                                          background-color:#059669;
                                          color:#ffffff;
                                          text-decoration:none;
                                          font-size:14.5px;
                                          font-weight:bold;
                                          border-radius:8px;
                                          margin:4px 6px;">
                                    📞 Call Devotee
                                </a>
                                ''' : ''}
                                <a href="https://pavanputragarbi.web.app/#/admin" target="_blank" rel="noopener noreferrer" style="display:inline-block;
                                          padding:12px 28px;
                                          background-color:#1a49ba;
                                          color:#ffffff;
                                          text-decoration:none;
                                          font-size:14.5px;
                                          font-weight:bold;
                                          border-radius:8px;
                                          margin:4px 6px;">
                                    🌐 Open Admin Portal
                                </a>
                            </td>
                        </tr>

                        <!-- Inner Footer (Company Info) -->
                        <tr>
                            <td align="center" style="background-color:#f8fafc;
                                       padding:30px 20px;
                                       border-top:1px solid #e2e8f0;">

                                <div style="font-size:22px; margin-bottom:10px;">🏛️</div>

                                <div style="font-size:15px;
                                            color:#0f172a;
                                            font-weight:bold;
                                            margin-bottom:6px;">
                                    $mandalGu
                                </div>
                                <div style="font-size:12px;
                                            color:#64748b;
                                            font-weight:600;
                                            margin-bottom:8px;">
                                    $mandalEn
                                </div>

                                <div style="font-size:12px;
                                            color:#64748b;
                                            line-height:1.6;">
                                    $address<br>
                                    Helpline: $phone • Aarti: $aarti
                                </div>

                            </td>
                        </tr>

                    </tbody>
                </table>

                <!-- Main Footer -->
                <table width="100%" border="0" cellpadding="0" cellspacing="0" style="max-width:600px;
                              margin-top:20px;">
                    <tbody>
                        <tr>
                            <td align="center">
                                <p style="margin:0;
                                          font-size:12px;
                                          color:#94a3b8;
                                          line-height:1.5;">
                                    This is an automated email from pavanputragarbi mandal. Please do not reply directly.
                                </p>
                            </td>
                        </tr>
                    </tbody>
                </table>

            </td>
        </tr>
    </tbody>
</table>
</body>
</html>
''';
  }

  String _buildTestHtml({required AdminNotificationEmail recipient, required String timestamp}) {
    final logoUrl = _getLogoUrl();
    final mandalGu = _getMandalNameGu();
    final mandalEn = _getMandalNameEn();
    final address = _getVenueAddress();

    return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Admin Notification System Active — $mandalEn</title>
</head>
<body style="margin:0;padding:0;background-color:#f4f7f6;">
<table width="100%" border="0" cellpadding="0" cellspacing="0" style="background-color:#f4f7f6; padding:40px 15px; font-family: Arial, sans-serif;">
    <tbody>
        <tr>
            <td align="center">
                <table width="100%" border="0" cellpadding="0" cellspacing="0" style="max-width:600px;
                              background-color:#ffffff;
                              border-radius:12px;
                              overflow:hidden;
                              box-shadow:0 4px 15px rgba(0,0,0,0.05);
                              border:1px solid #e2e8f0;">
                    <tbody>
                        <tr>
                            <td align="center" style="padding:40px 30px 20px 30px;">
                                <img src="$logoUrl" alt="Mandal Logo" width="120" height="120" style="display:block;
                                            border:0;
                                            margin:0 auto 25px auto;
                                            border-radius:50%;
                                            object-fit:cover;
                                            border:2px solid #C5A059;
                                            background-color:#ffffff;">

                                <h1 style="margin:0;
                                           color:#0a1332;
                                           font-size:24px;
                                           font-weight:700;
                                           margin-bottom:8px;">
                                    Notification System Verified
                                </h1>

                                <div style="color:#C5A059; font-size:14px; font-weight:bold; margin-bottom:14px;">
                                    $mandalGu
                                </div>

                                <p style="margin:0 auto;
                                          color:#5a667b;
                                          font-size:15px;
                                          line-height:1.6;
                                          max-width:480px;
                                          text-align:center;">
                                    Your administrative notification address has been successfully verified for receiving live website inquiries.
                                </p>
                            </td>
                        </tr>

                        <tr>
                            <td style="padding:10px 30px 20px 30px;">
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" style="background-color:#f8fafc;
                                              border:1px solid #e2e8f0;
                                              border-radius:8px;">
                                    <tbody>
                                        <tr>
                                            <td style="padding:20px 24px; font-size:14px; line-height:1.7;">
                                                <div style="margin-bottom:10px;">
                                                    <strong style="color:#334155;">Officer Name:</strong>
                                                    <span style="color:#0f172a; font-weight:bold; margin-left:8px;">${recipient.recipientName}</span>
                                                </div>
                                                <div style="margin-bottom:10px;">
                                                    <strong style="color:#334155;">Department:</strong>
                                                    <span style="color:#0f172a; margin-left:8px;">${recipient.department}</span>
                                                </div>
                                                <div style="margin-bottom:10px;">
                                                    <strong style="color:#334155;">Verified Email:</strong>
                                                    <span style="color:#1e3a8a; font-weight:bold; margin-left:8px;">${recipient.email}</span>
                                                </div>
                                                <div>
                                                    <strong style="color:#334155;">Timestamp:</strong>
                                                    <span style="color:#64748b; margin-left:8px;">$timestamp</span>
                                                </div>
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </td>
                        </tr>

                        <tr>
                            <td align="center" style="padding:10px 30px 34px 30px;">
                                <a href="https://pavanputragarbi.web.app/#/admin" target="_blank" rel="noopener noreferrer" style="display:inline-block;
                                          padding:14px 32px;
                                          background-color:#1a49ba;
                                          color:#ffffff;
                                          text-decoration:none;
                                          font-size:15px;
                                          font-weight:bold;
                                          border-radius:8px;">
                                    🌐 Go to Admin Portal
                                </a>
                            </td>
                        </tr>

                        <tr>
                            <td align="center" style="background-color:#f8fafc; padding:30px 20px; border-top:1px solid #e2e8f0;">
                                <div style="font-size:20px; margin-bottom:10px;">🏢</div>
                                <div style="font-size:15px; color:#0f172a; font-weight:bold; margin-bottom:6px;">$mandalGu ($mandalEn)</div>
                                <div style="font-size:12px; color:#64748b; line-height:1.6;">$address</div>
                            </td>
                        </tr>
                    </tbody>
                </table>

                <table width="100%" border="0" cellpadding="0" cellspacing="0" style="max-width:600px; margin-top:20px;">
                    <tbody>
                        <tr>
                            <td align="center">
                                <p style="margin:0; font-size:12px; color:#94a3b8; line-height:1.5;">
                                    This is an automated verification email from pavanputragarbi mandal.
                                </p>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </td>
        </tr>
    </tbody>
</table>
</body>
</html>
''';
  }

  /// Generates Forgot Password HTML email matching the exact template provided by the user.
  String _buildForgotPasswordHtml({required String email, required String resetLink}) {
    final logoUrl = _getLogoUrl();
    final mandalGu = _getMandalNameGu();
    final mandalEn = _getMandalNameEn();
    final address = _getVenueAddress();

    return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Forgot Password — $mandalEn</title>
</head>
<body style="margin:0;padding:0;background-color:#f4f7f6;">
<table width="100%" border="0" cellpadding="0" cellspacing="0" style="background-color:#f4f7f6; padding:40px 15px; font-family: Arial, sans-serif;">
    <tbody>
        <tr>
            <td align="center">

                <!-- Main Content Container -->
                <table width="100%" border="0" cellpadding="0" cellspacing="0" style="max-width:600px;
                              background-color:#ffffff;
                              border-radius:12px;
                              overflow:hidden;
                              box-shadow:0 4px 15px rgba(0,0,0,0.05);
                              border:1px solid #e2e8f0;">

                    <tbody>
                        <!-- Header Section -->
                        <tr>
                            <td align="center" style="padding:40px 30px 20px 30px;">

                                <!-- Logo -->
                                <img src="$logoUrl" alt="Mandal Logo" width="120" height="120" style="display:block;
                                            border:0;
                                            margin:0 auto 25px auto;
                                            border-radius:50%;
                                            object-fit:cover;
                                            border:2px solid #C5A059;
                                            background-color:#ffffff;">

                                <h1 style="margin:0;
                                           color:#0a1332;
                                           font-size:26px;
                                           font-weight:700;
                                           margin-bottom:15px;">
                                    Forgot Password
                                </h1>

                                <p style="margin:0 auto;
                                          color:#5a667b;
                                          font-size:15px;
                                          line-height:1.6;
                                          max-width:480px;
                                          text-align:center;">
                                    We received a request to reset the password
                                    for your account. Click the button below to
                                    securely reset your password.
                                </p>

                                <!-- Primary Button -->
                                <table border="0" cellpadding="0" cellspacing="0" style="margin-top:30px;">
                                    <tbody>
                                        <tr>
                                            <td align="center" bgcolor="#1a49ba" style="border-radius:8px;">
                                                <a href="$resetLink" target="_blank" rel="noopener noreferrer" style="display:inline-block;
                                                          padding:14px 32px;
                                                          color:#ffffff;
                                                          text-decoration:none;
                                                          font-size:16px;
                                                          font-weight:bold;
                                                          border-radius:8px;">
                                                    🔐 Reset Password
                                                </a>
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>

                            </td>
                        </tr>

                        <!-- Account Summary (Only Email) -->
                        <tr>
                            <td style="padding:10px 30px 20px 30px;">
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" style="background-color:#f8fafc;
                                              border:1px solid #e2e8f0;
                                              border-radius:8px;">
                                    <tbody>
                                        <tr>
                                            <!-- Email Only -->
                                            <td align="center" style="padding:20px 10px;">
                                                <div style="font-size:20px; margin-bottom:8px;">✉️</div>
                                                <div style="color:#64748b;
                                                            font-size:12px;
                                                            margin-bottom:8px;">
                                                    Registered Email
                                                </div>
                                                <div style="color:#1e3a8a;
                                                            font-size:14px;
                                                            font-weight:bold;
                                                            word-break:break-word;">
                                                    $email
                                                </div>
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </td>
                        </tr>

                        <!-- Security Notice -->
                        <tr>
                            <td style="padding:20px 30px 20px 30px;">
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" style="background-color:#f8fafc;
                                              border-left:4px solid #1a49ba;
                                              border-radius:8px;">
                                    <tbody>
                                        <tr>
                                            <td style="padding:18px 20px;
                                                       font-size:13px;
                                                       line-height:1.6;
                                                       color:#475569;">
                                                <strong style="color:#0f172a;">
                                                    Security Notice
                                                </strong>
                                                <br><br>
                                                If you did not request a password
                                                reset, you can safely ignore this
                                                email. Your password will remain
                                                unchanged.
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </td>
                        </tr>

                        <!-- Action Button (Second) -->
                        <tr>
                            <td align="center" style="padding:10px 30px 40px 30px;">
                                <a href="$resetLink" target="_blank" rel="noopener noreferrer" style="display:inline-block;
                                          padding:12px 28px;
                                          background-color:#1a49ba;
                                          color:#ffffff;
                                          text-decoration:none;
                                          font-size:15px;
                                          font-weight:bold;
                                          border-radius:8px;
                                          border:1px solid #1a49ba;">
                                    🔐 Reset Password
                                </a>
                            </td>
                        </tr>

                        <!-- Inner Footer (Company Info) -->
                        <tr>
                            <td align="center" style="background-color:#f8fafc;
                                       padding:30px 20px;
                                       border-top:1px solid #e2e8f0;">

                                <div style="font-size:20px; margin-bottom:10px;">🏢</div>

                                <div style="font-size:15px;
                                            color:#0f172a;
                                            font-weight:bold;
                                            margin-bottom:6px;">
                                    $mandalGu ($mandalEn)
                                </div>

                                <div style="font-size:12px;
                                            color:#64748b;
                                            line-height:1.6;">
                                    $address
                                </div>

                            </td>
                        </tr>

                    </tbody>
                </table>

                <!-- Main Footer -->
                <table width="100%" border="0" cellpadding="0" cellspacing="0" style="max-width:600px;
                              margin-top:20px;">
                    <tbody>
                        <tr>
                            <td align="center">
                                <p style="margin:0;
                                          font-size:12px;
                                          color:#94a3b8;
                                          line-height:1.5;">
                                    This is an automated email from pavanputragarbi mandal.
                                    Please do not reply.
                                </p>
                            </td>
                        </tr>
                    </tbody>
                </table>

            </td>
        </tr>
    </tbody>
</table>
</body>
</html>
''';
  }

  String _buildResponseHtml({
    required AdminEnquiry enquiry,
    required String replyMessage,
    required String senderName,
    required String senderEmail,
  }) {
    final logoUrl = _getLogoUrl();
    final mandalGu = _getMandalNameGu();
    final mandalEn = _getMandalNameEn();
    final address = _getVenueAddress();
    final aarti = _getAartiSchedule();
    final phone = _getContactPhone();

    return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Response from $mandalEn</title>
</head>
<body style="margin:0;padding:24px 12px;background-color:#FAF6EE;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Helvetica,Arial,sans-serif;color:#222;">
  <div style="max-width:620px;margin:0 auto;background:#FFFFFF;border-radius:16px;overflow:hidden;border:1.5px solid #C5A059;box-shadow:0 8px 24px rgba(74,0,11,0.08);">
    
    <div style="height:6px;background:linear-gradient(90deg, #946E24 0%, #D4AF37 50%, #946E24 100%);"></div>

    <div style="background-color:#4A000B;padding:28px 20px 22px 20px;text-align:center;border-bottom:3px solid #C5A059;">
      <p style="margin:0 0 12px 0;color:#E6C875;font-size:12.5px;letter-spacing:2px;font-weight:700;">|| જય માતાજી || || જાગતી જોગમાયા ||</p>
      <div style="text-align:center;margin-bottom:12px;">
        <img src="$logoUrl" alt="Shree Pavan Putra Garbi Mandal" width="82" height="82" style="width:82px;height:82px;object-fit:cover;border-radius:50%;border:3px solid #C5A059;box-shadow:0 4px 14px rgba(0,0,0,0.35);vertical-align:middle;background-color:#FAF6EE;display:inline-block;" />
      </div>
      <h1 style="margin:0 0 4px 0;color:#FFFFFF;font-size:22px;font-weight:800;">$mandalGu</h1>
      <h2 style="margin:0;color:#F0D590;font-size:12px;font-weight:700;letter-spacing:2px;text-transform:uppercase;">$mandalEn Trust — Rajkot</h2>
    </div>

    <div style="padding:28px 24px;">
      <p style="font-size:16px;color:#4A000B;font-weight:800;margin:0 0 14px 0;">
        Pranam ${enquiry.name} ji (પ્રણામ ${enquiry.name} જી),
      </p>

      <div style="background:#FFFDF9;border:1px solid #E5D5B8;border-left:4px solid #C5A059;border-radius:10px;padding:18px 20px;color:#222222;font-size:14.5px;line-height:1.7;margin-bottom:24px;">
        $replyMessage
      </div>

      <!-- Quoted Devotee Original Inquiry -->
      <div style="background:#FAF8F3;border:1px dashed #DCCDB2;border-radius:8px;padding:14px 16px;margin-bottom:24px;font-size:12.5px;color:#666666;">
        <div style="font-weight:700;color:#4A000B;margin-bottom:4px;">Regarding your inquiry submitted on ${enquiry.date}:</div>
        <div style="font-style:italic;">"${enquiry.message}"</div>
      </div>

      <!-- Mandal Official Signature Block -->
      <div style="border-top:1.5px solid #E8DCBF;padding-top:18px;font-size:13px;color:#444444;">
        <p style="margin:0;font-weight:700;color:#4A000B;">Warm regards & Divine blessings,</p>
        <p style="margin:4px 0 2px 0;font-weight:800;color:#111111;font-size:15px;">$senderName</p>
        <p style="margin:0;color:#7A5812;font-weight:600;">$mandalGu</p>
        <p style="margin:2px 0 0 0;color:#888888;">Official Email: $senderEmail</p>
      </div>
    </div>

    <div style="background:#FAF6EE;padding:18px 22px;text-align:center;border-top:1px solid #E8DCBF;color:#666666;font-size:11.5px;line-height:1.6;">
      <p style="margin:0 0 4px 0;font-weight:700;color:#7A5812;">|| જાગતી જોગમાયા || || જય માતાજી ||</p>
      <p style="margin:0 0 4px 0;color:#4A000B;font-weight:600;">📍 $address</p>
      <p style="margin:0;">⏰ $aarti • 📞 $phone</p>
    </div>

  </div>
</body>
</html>
''';
  }
}


