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
      try {
        final success = await _dispatchEmailViaGateway(
          toEmail: email,
          subject: '🕉️ New Devotee Inquiry: ${enquiry.name} — ${_getMandalNameGu()}',
          fields: {
            '🏛️ Mandal / સંસ્થા': '${_getMandalNameGu()} (${_getMandalNameEn()})',
            '🙏 Sacred Invocation': '|| શ્રી ગણેશાય નમઃ || || ૐ નમઃ શિવાય || || જય માતાજી ||',
            '👤 Devotee Name (ભાવિકનું નામ)': enquiry.name,
            '📞 Helpline / Phone (ફોન)': enquiry.phone.isNotEmpty ? enquiry.phone : 'Not provided',
            '✉️ Devotee Email (ઈમેલ)': enquiry.email.isNotEmpty ? enquiry.email : 'Not provided',
            '📅 Submission Date (તારીખ)': enquiry.date,
            '📝 Devotee Message / Prayer Request (સંદેશ)': enquiry.message,
            '📍 Mandal Venue / સરનામું': _getVenueAddress(),
            '⏰ Aarti Timings / આરતી સમય': _getAartiSchedule(),
            '🎯 Routed Recipient / લક્ષ્ય ઈમેલ': email,
            '🌐 Admin Portal Link': 'https://pavanputragarbi.web.app/#/admin',
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
              'subject': '🕉️ New Devotee Inquiry: ${enquiry.name} — ${_getMandalNameGu()}',
              'text': _buildPlainTextNotification(enquiry: enquiry, recipientEmail: email),
              'html': _buildHtmlNotification(enquiry: enquiry, recipientEmail: email),
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
        subject: '✅ Verification: ${_getMandalNameGu()} Admin Mail System Active',
        fields: {
          '🏛️ Mandal / સંસ્થા': '${_getMandalNameGu()} (${_getMandalNameEn()})',
          '🙏 Sacred Invocation': '|| શ્રી ગણેશાય નમઃ || || જય માતાજી || || ૐ નમઃ શિવાય ||',
          '🔔 System Status': 'ACTIVE & OPERATIONAL (સક્રિય અને ચકાસાયેલ)',
          '👤 Recipient Officer / અધિકારી': recipient.recipientName,
          '🏢 Department / વિભાગ': recipient.department,
          '✉️ Verified Address / ઈમેલ': email,
          '📅 Verification Time / સમય': timestampStr,
          '📍 Mandal Venue / સરનામું': _getVenueAddress(),
          '💬 System Notice': 'Devotee messages submitted from the public contact form will be delivered to this verified administrative address.',
          '🌐 Admin Portal Link': 'https://pavanputragarbi.web.app/#/admin',
        },
      );

      // Also record in Firestore
      try {
        await FirebaseFirestore.instance.collection('mail').add({
          'to': [email],
          'message': {
            'subject': '✅ Verification: ${_getMandalNameGu()} Admin Mail System Active',
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

  String _buildHtmlNotification({required AdminEnquiry enquiry, required String recipientEmail}) {
    final logoUrl = _getLogoUrl();
    final mandalGu = _getMandalNameGu();
    final mandalEn = _getMandalNameEn();
    final address = _getVenueAddress();
    final aarti = _getAartiSchedule();
    final phone = _getContactPhone();
    final refId = enquiry.id.isNotEmpty
        ? enquiry.id
        : DateTime.now().millisecondsSinceEpoch.toString().substring(7);

    return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>New Devotee Inquiry — $mandalEn</title>
</head>
<body style="margin:0;padding:24px 12px;background-color:#FAF6EE;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Helvetica,Arial,sans-serif;-webkit-font-smoothing:antialiased;color:#222222;">
  <div style="max-width:620px;margin:0 auto;background:#FFFFFF;border-radius:16px;overflow:hidden;border:1.5px solid #C5A059;box-shadow:0 8px 24px rgba(74,0,11,0.08);">
    
    <!-- Top Ornamental Gradient Bar -->
    <div style="height:6px;background:linear-gradient(90deg, #946E24 0%, #D4AF37 25%, #FFF0B8 50%, #D4AF37 75%, #946E24 100%);"></div>

    <!-- Royal Header with Brand Logo & Bilingual Titles -->
    <div style="background-color:#4A000B;padding:28px 20px 22px 20px;text-align:center;border-bottom:3px solid #C5A059;">
      <p style="margin:0 0 12px 0;color:#E6C875;font-size:12.5px;letter-spacing:2px;font-weight:700;">|| શ્રી ગણેશાય નમઃ || || ૐ નમઃ શિવાય || || જય માતાજી ||</p>
      
      <!-- Mandal Brand Logo -->
      <div style="text-align:center;margin-bottom:12px;">
        <img src="$logoUrl" alt="Shree Pavan Putra Garbi Mandal Logo" width="82" height="82" style="width:82px;height:82px;object-fit:cover;border-radius:50%;border:3px solid #C5A059;box-shadow:0 4px 14px rgba(0,0,0,0.35);vertical-align:middle;background-color:#FAF6EE;display:inline-block;" />
      </div>

      <!-- Mandal Title in Gujarati & English -->
      <h1 style="margin:0 0 4px 0;color:#FFFFFF;font-size:22px;font-weight:800;letter-spacing:0.5px;">$mandalGu</h1>
      <h2 style="margin:0 0 12px 0;color:#F0D590;font-size:12px;font-weight:700;letter-spacing:2px;text-transform:uppercase;">$mandalEn — RAJKOT</h2>
      
      <!-- Official Badge -->
      <div style="display:inline-block;background:rgba(197,160,89,0.22);border:1px solid #C5A059;border-radius:20px;padding:5px 16px;color:#FCE8B3;font-size:11px;font-weight:700;letter-spacing:0.8px;">
        🏛️ OFFICIAL MANDAL INBOX • આધિકારિક મંડળ સૂચના
      </div>
    </div>

    <!-- Main Content Container -->
    <div style="padding:26px 24px;">
      
      <!-- Alert Box -->
      <div style="background:#FFF9EE;border-left:4px solid #C5A059;border-top:1px solid #EFE4D0;border-right:1px solid #EFE4D0;border-bottom:1px solid #EFE4D0;padding:14px 16px;border-radius:8px;margin-bottom:22px;">
        <div style="color:#4A000B;font-size:14px;font-weight:800;margin-bottom:2px;">
          📬 New Public Inquiry Received from <strong>${enquiry.name}</strong>
        </div>
        <div style="color:#7A5812;font-size:12px;">
          Reference ID: <span style="font-family:monospace;font-weight:700;color:#4A000B;">#PPGM-$refId</span> • Date: <strong>${enquiry.date}</strong>
        </div>
      </div>

      <!-- Devotee Details Table -->
      <table style="width:100%;border-collapse:collapse;margin-bottom:22px;font-size:13.5px;">
        <tr>
          <td style="padding:11px 14px;background:#FAF6EE;font-weight:700;color:#4A000B;width:34%;border:1px solid #EADFC9;">
            👤 Devotee Name<br><span style="font-size:11px;color:#7A5812;font-weight:normal;">ભાવિકનું નામ</span>
          </td>
          <td style="padding:11px 14px;border:1px solid #EADFC9;color:#111111;font-weight:700;">
            ${enquiry.name}
          </td>
        </tr>
        <tr>
          <td style="padding:11px 14px;background:#FAF6EE;font-weight:700;color:#4A000B;border:1px solid #EADFC9;">
            📞 Contact Phone<br><span style="font-size:11px;color:#7A5812;font-weight:normal;">ફોન નંબર</span>
          </td>
          <td style="padding:11px 14px;border:1px solid #EADFC9;color:#222222;">
            ${enquiry.phone.isNotEmpty ? '<a href="tel:${enquiry.phone}" style="color:#4A000B;font-weight:700;text-decoration:none;">📞 ${enquiry.phone}</a>' : '<span style="color:#888888;">Not provided</span>'}
          </td>
        </tr>
        <tr>
          <td style="padding:11px 14px;background:#FAF6EE;font-weight:700;color:#4A000B;border:1px solid #EADFC9;">
            ✉️ Email Address<br><span style="font-size:11px;color:#7A5812;font-weight:normal;">ઈમેલ એડ્રેસ</span>
          </td>
          <td style="padding:11px 14px;border:1px solid #EADFC9;color:#222222;">
            ${enquiry.email.isNotEmpty ? '<a href="mailto:${enquiry.email}" style="color:#C5A059;font-weight:700;text-decoration:none;">✉️ ${enquiry.email}</a>' : '<span style="color:#888888;">Not provided</span>'}
          </td>
        </tr>
        <tr>
          <td style="padding:11px 14px;background:#FAF6EE;font-weight:700;color:#4A000B;border:1px solid #EADFC9;">
            🎯 Routed Target<br><span style="font-size:11px;color:#7A5812;font-weight:normal;">સૂચના પ્રાપ્તકર્તા</span>
          </td>
          <td style="padding:11px 14px;border:1px solid #EADFC9;color:#555555;font-size:12.5px;">
            $recipientEmail
          </td>
        </tr>
      </table>

      <!-- Message Parchment Box -->
      <div style="margin-bottom:24px;">
        <div style="color:#4A000B;font-size:12.5px;font-weight:800;letter-spacing:1px;text-transform:uppercase;margin-bottom:8px;">
          📝 DEVOTEE MESSAGE / PRAYER REQUEST (ભાવિકનો સંદેશ):
        </div>
        <div style="background:#FFFDF9;border:1px solid #E5D5B8;border-left:4px solid #C5A059;border-radius:10px;padding:18px 20px;font-size:14.5px;line-height:1.7;color:#261611;">
          "${enquiry.message}"
        </div>
      </div>

      <!-- Quick Action Buttons -->
      <div style="text-align:center;margin:24px 0 12px 0;">
        ${enquiry.email.isNotEmpty ? '''
        <a href="mailto:${enquiry.email}?subject=Pranam ${enquiry.name} ji — $mandalGu" style="display:inline-block;background-color:#4A000B;color:#FFFFFF;padding:12px 22px;border-radius:8px;text-decoration:none;font-weight:700;font-size:13px;border:1.5px solid #C5A059;margin:4px 6px;">
          ✉️ Reply via Email
        </a>
        ''' : ''}
        ${enquiry.phone.isNotEmpty ? '''
        <a href="tel:${enquiry.phone}" style="display:inline-block;background-color:#1E5E2C;color:#FFFFFF;padding:12px 20px;border-radius:8px;text-decoration:none;font-weight:700;font-size:13px;border:1.5px solid #81C784;margin:4px 6px;">
          📞 Call Devotee
        </a>
        ''' : ''}
        <a href="https://pavanputragarbi.web.app/#/admin" style="display:inline-block;background-color:#FAF6EE;color:#4A000B;padding:12px 20px;border-radius:8px;text-decoration:none;font-weight:700;font-size:13px;border:1.5px solid #C5A059;margin:4px 6px;">
          🌐 Open Admin Portal
        </a>
      </div>

    </div>

    <!-- Sacred & Official Footer -->
    <div style="background:#FAF6EE;padding:20px 24px;text-align:center;border-top:1.5px solid #E8DCBF;color:#666666;font-size:11.5px;line-height:1.6;">
      <p style="margin:0 0 6px 0;font-weight:700;color:#7A5812;font-size:12.5px;">|| જાગતી જોગમાયા || || જય માતાજી || || ૐ નમઃ શિવાય ||</p>
      <p style="margin:0 0 4px 0;color:#4A000B;font-weight:600;">📍 $address</p>
      <p style="margin:0 0 8px 0;color:#555555;">⏰ $aarti • 📞 Helpline: $phone</p>
      <div style="height:1px;background:#E2D3B8;margin:10px auto;max-width:300px;"></div>
      <p style="margin:0;color:#888888;font-size:11px;">© 2026 $mandalEn, Rajkot • All Rights Reserved</p>
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
  <title>System Verification — $mandalEn</title>
</head>
<body style="margin:0;padding:24px 12px;background-color:#FAF6EE;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;color:#222;">
  <div style="max-width:600px;margin:0 auto;background:#FFFFFF;border-radius:16px;overflow:hidden;border:1.5px solid #C5A059;box-shadow:0 8px 24px rgba(74,0,11,0.08);">
    
    <div style="height:6px;background:linear-gradient(90deg, #946E24 0%, #D4AF37 50%, #946E24 100%);"></div>

    <div style="background-color:#4A000B;padding:26px 20px;text-align:center;border-bottom:3px solid #C5A059;">
      <p style="margin:0 0 10px 0;color:#E6C875;font-size:12px;letter-spacing:1.5px;font-weight:700;">|| શ્રી ગણેશાય નમઃ || || જય માતાજી ||</p>
      <img src="$logoUrl" alt="Logo" width="76" height="76" style="width:76px;height:76px;object-fit:cover;border-radius:50%;border:3px solid #C5A059;margin-bottom:10px;background:#FAF6EE;display:inline-block;" />
      <h2 style="margin:0;color:#FFFFFF;font-size:20px;font-weight:800;">✅ Admin Notification System Active</h2>
      <p style="margin:4px 0 0 0;color:#F0D590;font-size:12px;">$mandalGu — Email Verification Notice</p>
    </div>

    <div style="padding:26px 24px;">
      <p style="font-size:15px;margin:0 0 12px 0;">Pranam <strong>${recipient.recipientName}</strong>,</p>
      <p style="font-size:13.5px;line-height:1.6;color:#444;margin:0 0 18px 0;">
        Your administrative notification address (<strong>${recipient.email}</strong>) has been successfully verified in the <strong>$mandalEn</strong> portal for the <strong>${recipient.department}</strong> department.
      </p>

      <div style="background:#E8F5E9;border:1.5px solid #81C784;border-radius:10px;padding:14px 16px;margin:18px 0;font-size:13px;color:#1B5E20;line-height:1.5;">
        <strong>✓ Live Notifications Enabled:</strong> Whenever devotees submit prayer requests or messages on the public Contact page, complete inquiries will immediately arrive formatted to this inbox.
      </div>

      <table style="width:100%;border-collapse:collapse;margin:18px 0;font-size:13px;">
        <tr>
          <td style="padding:8px 12px;background:#FAF6EE;font-weight:bold;color:#4A000B;border:1px solid #EAE0CE;width:35%;">Department:</td>
          <td style="padding:8px 12px;border:1px solid #EAE0CE;">${recipient.department}</td>
        </tr>
        <tr>
          <td style="padding:8px 12px;background:#FAF6EE;font-weight:bold;color:#4A000B;border:1px solid #EAE0CE;">Primary Recipient:</td>
          <td style="padding:8px 12px;border:1px solid #EAE0CE;">${recipient.isPrimary ? 'Yes (મુખ્ય પ્રાપ્તકર્તા)' : 'Secondary'}</td>
        </tr>
        <tr>
          <td style="padding:8px 12px;background:#FAF6EE;font-weight:bold;color:#4A000B;border:1px solid #EAE0CE;">Verified Time:</td>
          <td style="padding:8px 12px;border:1px solid #EAE0CE;">$timestamp</td>
        </tr>
      </table>

      <div style="text-align:center;margin-top:22px;">
        <a href="https://pavanputragarbi.web.app/#/admin" style="display:inline-block;background-color:#4A000B;color:#FFFFFF;padding:11px 22px;border-radius:8px;text-decoration:none;font-weight:700;font-size:13px;border:1px solid #C5A059;">
          🌐 Go to Admin Portal
        </a>
      </div>
    </div>

    <div style="background:#FAF6EE;padding:16px 20px;text-align:center;border-top:1px solid #E8DCBF;color:#666666;font-size:11px;">
      <p style="margin:0 0 4px 0;font-weight:700;color:#7A5812;">|| જાગતી જોગમાયા || || જય માતાજી ||</p>
      <p style="margin:0;">$mandalEn Trust • $address</p>
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


