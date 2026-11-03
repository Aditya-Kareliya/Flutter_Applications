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
    return val.isNotEmpty ? val : '+91 94282 89998 / +91 98765 43210';
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
          subject: 'New Devotee Inquiry Received — ${_getMandalNameGu()}',
          fields: {
            'Recipient': recipientName,
            'Devotee Name': enquiry.name,
            'Contact Phone': enquiry.phone.isNotEmpty ? enquiry.phone : 'Not provided',
            'Email Address': enquiry.email.isNotEmpty ? enquiry.email : 'Not provided',
            'Submission Date': enquiry.date,
            'Inquiry Message': enquiry.message,
            'Mandal': '${_getMandalNameGu()} (${_getMandalNameEn()})',
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
              'subject': 'New Devotee Inquiry Received — ${_getMandalNameGu()}',
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
        subject: 'Admin Notification System Active — ${_getMandalNameGu()}',
        fields: {
          'System Status': 'Active & Operational',
          'Officer Name': recipient.recipientName,
          'Department': recipient.department,
          'Verified Email': email,
          'Verified Time': timestampStr,
          'Mandal': '${_getMandalNameGu()} (${_getMandalNameEn()})',
          'Notice': 'Devotee inquiries submitted on the public Contact page will arrive at this address.',
        },
      );

      // Also record in Firestore
      try {
        await FirebaseFirestore.instance.collection('mail').add({
          'to': [email],
          'message': {
            'subject': 'Admin Notification System Active — ${_getMandalNameGu()}',
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
        subject: 'Forgot Password — ${_getMandalNameGu()}',
        fields: {
          'Action': 'Password Reset Request',
          'Registered Email': cleanEmail,
          'Reset Link': link,
          'Mandal': '${_getMandalNameGu()} (${_getMandalNameEn()})',
          'Security Notice': 'If you did not request a password reset, you can safely ignore this email. Your password will remain unchanged.',
        },
      );

      // Record in Firestore `mail` collection
      try {
        await FirebaseFirestore.instance.collection('mail').add({
          'to': [cleanEmail],
          'message': {
            'subject': 'Forgot Password — ${_getMandalNameGu()}',
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
    final nameGreeting = (recipientName != null && recipientName.isNotEmpty) ? recipientName : 'Administrator';

    return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>New Devotee Inquiry Received — $mandalEn</title>
</head>
<body style="margin:0;padding:32px 14px;background-color:#F0F4F8;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Helvetica,Arial,sans-serif;-webkit-font-smoothing:antialiased;color:#1E293B;">
  <div style="max-width:580px;margin:0 auto;background:#FFFFFF;border-radius:12px;overflow:hidden;box-shadow:0 4px 20px rgba(0,0,0,0.06);border:1px solid #E2E8F0;">
    
    <!-- Top Solid Brand Header with Centered Logo (Matches MedSaral Style) -->
    <div style="background-color:#205482;padding:32px 20px 26px 20px;text-align:center;">
      <div style="text-align:center;margin-bottom:14px;">
        <img src="$logoUrl" alt="Mandal Logo" width="76" height="76" style="width:76px;height:76px;object-fit:cover;border-radius:50%;border:3px solid rgba(255,255,255,0.85);display:inline-block;background-color:#FFFFFF;" />
      </div>
      <h1 style="margin:0;color:#FFFFFF;font-size:22px;font-weight:700;letter-spacing:0.3px;line-height:1.3;">New Devotee Inquiry Received</h1>
      <p style="margin:4px 0 0 0;color:#CBD5E1;font-size:12px;letter-spacing:0.5px;">$mandalGu</p>
    </div>

    <!-- White Content Body -->
    <div style="padding:32px 28px;">
      <h2 style="font-size:17px;font-weight:700;color:#0F172A;margin:0 0 10px 0;">Dear $nameGreeting,</h2>
      <p style="font-size:14px;color:#475569;line-height:1.55;margin:0 0 24px 0;">
        A new devotee inquiry has been submitted for you. Please review the details below.
      </p>

      <!-- Rounded Details Card Container -->
      <div style="background-color:#F8FAFC;border-radius:10px;padding:20px 22px;margin-bottom:24px;border:1px solid #E2E8F0;">
        <div style="margin-bottom:12px;font-size:14px;">
          <strong style="color:#334155;">Devotee Name:</strong>
          <span style="color:#0F172A;font-weight:600;margin-left:8px;">${enquiry.name}</span>
        </div>
        <div style="margin-bottom:12px;font-size:14px;">
          <strong style="color:#334155;">Contact Phone:</strong>
          <span style="margin-left:8px;">${enquiry.phone.isNotEmpty ? '<a href="tel:${enquiry.phone}" style="color:#0284C7;text-decoration:none;font-weight:600;">${enquiry.phone}</a>' : '<span style="color:#94A3B8;">Not provided</span>'}</span>
        </div>
        <div style="margin-bottom:12px;font-size:14px;">
          <strong style="color:#334155;">Email Address:</strong>
          <span style="margin-left:8px;">${enquiry.email.isNotEmpty ? '<a href="mailto:${enquiry.email}" style="color:#0284C7;text-decoration:none;font-weight:600;">${enquiry.email}</a>' : '<span style="color:#94A3B8;">Not provided</span>'}</span>
        </div>
        <div style="margin-bottom:14px;font-size:14px;">
          <strong style="color:#334155;">Submission Date:</strong>
          <span style="color:#0F172A;margin-left:8px;">${enquiry.date}</span>
        </div>
        <div style="font-size:14px;">
          <strong style="color:#334155;display:block;margin-bottom:6px;">Inquiry / Prayer Request:</strong>
          <div style="background:#FFFFFF;border:1px solid #CBD5E1;border-radius:6px;padding:12px 14px;color:#0F172A;font-size:13.5px;line-height:1.6;">
            ${enquiry.message}
          </div>
        </div>
      </div>

      <p style="text-align:center;font-size:13px;color:#64748B;margin:0 0 24px 0;">
        Please contact the devotee for further consultation.
      </p>

      <!-- Quick Action Buttons -->
      <div style="text-align:center;margin-bottom:12px;">
        ${enquiry.email.isNotEmpty ? '''
        <a href="mailto:${enquiry.email}?subject=Pranam ${enquiry.name} ji — $mandalGu" style="display:inline-block;background-color:#205482;color:#FFFFFF;padding:12px 24px;border-radius:8px;text-decoration:none;font-weight:700;font-size:13px;margin:4px 6px;">
          ✉️ Reply via Email
        </a>
        ''' : ''}
        ${enquiry.phone.isNotEmpty ? '''
        <a href="tel:${enquiry.phone}" style="display:inline-block;background-color:#059669;color:#FFFFFF;padding:12px 22px;border-radius:8px;text-decoration:none;font-weight:700;font-size:13px;margin:4px 6px;">
          📞 Call Devotee
        </a>
        ''' : ''}
      </div>
    </div>

    <!-- Clean Footer -->
    <div style="border-top:1px solid #E2E8F0;padding:22px 24px;text-align:center;background:#FFFFFF;color:#64748B;font-size:12px;line-height:1.6;">
      <p style="margin:0 0 4px 0;font-weight:700;color:#334155;font-size:13px;">$mandalGu ($mandalEn)</p>
      <p style="margin:0 0 8px 0;font-size:11.5px;color:#64748B;">$address • Helpline: $phone</p>
      <p style="margin:0;color:#94A3B8;font-size:11px;">This is a securely generated message. Please do not reply directly to this email.</p>
    </div>

  </div>
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
<body style="margin:0;padding:32px 14px;background-color:#F0F4F8;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;color:#1E293B;">
  <div style="max-width:580px;margin:0 auto;background:#FFFFFF;border-radius:12px;overflow:hidden;box-shadow:0 4px 20px rgba(0,0,0,0.06);border:1px solid #E2E8F0;">
    
    <div style="background-color:#205482;padding:32px 20px 26px 20px;text-align:center;">
      <img src="$logoUrl" alt="Logo" width="76" height="76" style="width:76px;height:76px;object-fit:cover;border-radius:50%;border:3px solid rgba(255,255,255,0.85);display:inline-block;background:#FFFFFF;margin-bottom:12px;" />
      <h1 style="margin:0;color:#FFFFFF;font-size:22px;font-weight:700;">Admin Mail System Verified</h1>
      <p style="margin:4px 0 0 0;color:#CBD5E1;font-size:12px;">$mandalGu</p>
    </div>

    <div style="padding:32px 28px;">
      <h2 style="font-size:17px;font-weight:700;color:#0F172A;margin:0 0 10px 0;">Dear ${recipient.recipientName},</h2>
      <p style="font-size:14px;color:#475569;line-height:1.55;margin:0 0 20px 0;">
        Your administrative notification address (<strong>${recipient.email}</strong>) has been successfully verified for the <strong>${recipient.department}</strong> department.
      </p>

      <div style="background:#ECFDF5;border:1px solid #A7F3D0;border-radius:8px;padding:14px 18px;margin-bottom:22px;font-size:13px;color:#065F46;line-height:1.5;">
        <strong>✓ Operational:</strong> Whenever devotees submit inquiries on the public website, you will receive real-time notification alerts at this verified inbox.
      </div>

      <div style="background-color:#F8FAFC;border-radius:10px;padding:18px 20px;margin-bottom:24px;border:1px solid #E2E8F0;font-size:13.5px;">
        <div style="margin-bottom:10px;"><strong>Department:</strong> <span style="margin-left:8px;color:#334155;">${recipient.department}</span></div>
        <div style="margin-bottom:10px;"><strong>Primary Recipient:</strong> <span style="margin-left:8px;color:#334155;">${recipient.isPrimary ? 'Yes' : 'Secondary'}</span></div>
        <div><strong>Verified At:</strong> <span style="margin-left:8px;color:#334155;">$timestamp</span></div>
      </div>

      <div style="text-align:center;">
        <a href="https://pavanputragarbi.web.app/#/admin" style="display:inline-block;background-color:#205482;color:#FFFFFF;padding:12px 24px;border-radius:8px;text-decoration:none;font-weight:700;font-size:13px;">
          🌐 Open Admin Portal
        </a>
      </div>
    </div>

    <div style="border-top:1px solid #E2E8F0;padding:20px 24px;text-align:center;background:#FFFFFF;color:#64748B;font-size:11.5px;line-height:1.6;">
      <p style="margin:0 0 4px 0;font-weight:700;color:#334155;font-size:13px;">$mandalGu</p>
      <p style="margin:0 0 6px 0;">$address</p>
      <p style="margin:0;color:#94A3B8;font-size:11px;">This is a securely generated message. Please do not reply directly to this email.</p>
    </div>
  </div>
</body>
</html>
''';
  }

  /// Generates Forgot Password HTML email matching Image 3 design.
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
<body style="margin:0;padding:36px 14px;background-color:#F8FAFC;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Helvetica,Arial,sans-serif;-webkit-font-smoothing:antialiased;color:#1E293B;">
  <div style="max-width:540px;margin:0 auto;background:#FFFFFF;border-radius:12px;padding:42px 32px;box-shadow:0 4px 20px rgba(0,0,0,0.05);border:1px solid #E2E8F0;text-align:center;">
    
    <!-- Mandal Brand Logo -->
    <div style="text-align:center;margin-bottom:20px;">
      <img src="$logoUrl" alt="Mandal Logo" width="80" height="80" style="width:80px;height:80px;object-fit:cover;border-radius:50%;border:2px solid #E2E8F0;display:inline-block;background-color:#FFFFFF;" />
    </div>

    <!-- Title -->
    <h1 style="font-size:24px;font-weight:800;color:#0F172A;margin:0 0 12px 0;">Forgot Password</h1>

    <!-- Description -->
    <p style="font-size:14px;color:#475569;line-height:1.6;margin:0 auto 28px auto;max-width:440px;">
      We received a request to reset the password for your account. Click the button below to securely reset your password.
    </p>

    <!-- Primary Reset Password Button -->
    <div style="margin-bottom:28px;">
      <a href="$resetLink" style="display:inline-block;background-color:#1D4ED8;color:#FFFFFF;font-size:14.5px;font-weight:700;padding:13px 32px;border-radius:8px;text-decoration:none;box-shadow:0 2px 8px rgba(29,78,216,0.25);">
        🔐 Reset Password
      </a>
    </div>

    <!-- Registered Email Card -->
    <div style="background:#F8FAFC;border:1px solid #E2E8F0;border-radius:8px;padding:18px 20px;margin-bottom:24px;text-align:center;">
      <div style="font-size:22px;margin-bottom:4px;color:#64748B;">✉️</div>
      <div style="font-size:11.5px;color:#64748B;font-weight:600;text-transform:uppercase;letter-spacing:0.5px;">Registered Email</div>
      <div style="font-size:15px;font-weight:800;color:#1E3A8A;margin-top:4px;">$email</div>
    </div>

    <!-- Security Notice Card -->
    <div style="background:#F8FAFC;border-left:4px solid #1D4ED8;padding:16px 20px;text-align:left;margin-bottom:28px;border-radius:4px;border-top:1px solid #E2E8F0;border-right:1px solid #E2E8F0;border-bottom:1px solid #E2E8F0;">
      <div style="font-weight:800;color:#0F172A;font-size:13.5px;margin-bottom:6px;">Security Notice</div>
      <div style="color:#475569;font-size:13px;line-height:1.5;">
        If you did not request a password reset, you can safely ignore this email. Your password will remain unchanged.
      </div>
    </div>

    <!-- Secondary Reset Password Button -->
    <div style="margin-bottom:34px;">
      <a href="$resetLink" style="display:inline-block;background-color:#1D4ED8;color:#FFFFFF;font-size:14.5px;font-weight:700;padding:13px 32px;border-radius:8px;text-decoration:none;box-shadow:0 2px 8px rgba(29,78,216,0.25);">
        🔐 Reset Password
      </a>
    </div>

    <!-- Clean Footer -->
    <div style="border-top:1px solid #E2E8F0;padding-top:22px;text-align:center;color:#64748B;font-size:12px;line-height:1.6;">
      <p style="margin:0 0 4px 0;font-weight:700;color:#334155;font-size:13px;">$mandalGu</p>
      <p style="margin:0 0 8px 0;color:#64748B;font-size:11.5px;">$address</p>
      <p style="margin:0;color:#94A3B8;font-size:11px;">This is a securely generated message. Please do not reply directly to this email.</p>
    </div>

  </div>
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


