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
          subject: '🕉️ New Devotee Inquiry: ${enquiry.name} — Shree Pavan Putra Garbi Mandal',
          fields: {
            'Devotee Name': enquiry.name,
            'Phone Helpline': enquiry.phone.isNotEmpty ? enquiry.phone : 'Not provided',
            'Devotee Email': enquiry.email.isNotEmpty ? enquiry.email : 'Not provided',
            'Submission Date': enquiry.date,
            'Inquiry Message': enquiry.message,
            'Notification Target': email,
            'Portal': 'Shree Pavan Putra Garbi Mandal Rajkot',
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
              'subject': '🕉️ New Devotee Inquiry: ${enquiry.name} — Shree Pavan Putra Garbi Mandal',
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
        subject: '✅ Test Notification: Shree Pavan Putra Garbi Mandal Admin Mail System Working',
        fields: {
          'Test Status': 'SUCCESS — Notification Email System is Active & Operational',
          'Recipient Officer': recipient.recipientName,
          'Department': recipient.department,
          'Target Email': email,
          'Verification Time': timestampStr,
          'Mandal': 'Shree Pavan Putra Garbi Mandal Trust, Rajkot',
          'Message': 'This is a live test notification from your administration portal. When devotees submit messages on the Contact page, real inquiries will arrive formatted like this.',
        },
      );

      // Also record in Firestore
      try {
        await FirebaseFirestore.instance.collection('mail').add({
          'to': [email],
          'message': {
            'subject': '✅ Test Notification: Shree Pavan Putra Garbi Mandal Admin Mail System Working',
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
            : 'Pranam ${enquiry.name} ji — Response from Shree Pavan Putra Garbi Mandal',
        fields: {
          'Devotee Name': enquiry.name,
          'Response Message': replyMessage,
          'Responding Officer': senderName,
          'Mandal Email': senderEmail,
          'Original Inquiry': enquiry.message,
          'Mandal': 'Shree Pavan Putra Garbi Mandal, Rajkot',
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
|| શ્રી ગણેશાય નમઃ || || ૐ નમઃ શિવાય ||
SHREE PAVAN PUTRA GARBI MANDAL — RAJKOT
New Devotee Inquiry / Message Received

Devotee Name: ${enquiry.name}
Phone: ${enquiry.phone.isNotEmpty ? enquiry.phone : "Not provided"}
Email: ${enquiry.email.isNotEmpty ? enquiry.email : "Not provided"}
Date: ${enquiry.date}
Target: $recipientEmail

Inquiry Message:
${enquiry.message}

---
Visit Admin Portal to reply or update status.
|| જાગતી જોગમાયા || || જય માતાજી ||
''';
  }

  String _buildHtmlNotification({required AdminEnquiry enquiry, required String recipientEmail}) {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>New Devotee Inquiry</title>
</head>
<body style="margin:0;padding:24px;background-color:#FAF6EE;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Helvetica,Arial,sans-serif;">
  <div style="max-width:600px;margin:0 auto;background:#FFFFFF;border-radius:14px;overflow:hidden;border:1.5px solid #C5A059;box-shadow:0 6px 18px rgba(0,0,0,0.08);">
    <div style="background-color:#4A000B;padding:24px 20px;text-align:center;border-bottom:3px solid #C5A059;">
      <p style="margin:0 0 6px 0;color:#E6C875;font-size:13px;letter-spacing:1px;font-weight:600;">|| શ્રી ગણેશાય નમઃ || || ૐ નમઃ શિવાય ||</p>
      <h1 style="margin:0;color:#FFFFFF;font-size:22px;font-weight:700;">શ્રી પવન પુત્ર ગરબી મંડળ - રાજકોટ</h1>
      <p style="margin:4px 0 0 0;color:#F0D590;font-size:12px;">Shree Pavan Putra Garbi Mandal Trust — New Devotee Inquiry</p>
    </div>

    <div style="padding:24px;">
      <div style="background:#FFF9EE;border-left:4px solid #C5A059;padding:12px 16px;border-radius:4px;margin-bottom:20px;">
        <p style="margin:0;color:#4A000B;font-size:13px;font-weight:600;">New public website inquiry received from <strong>${enquiry.name}</strong></p>
        <p style="margin:2px 0 0 0;color:#7A5812;font-size:11.5px;">Date Submitted: ${enquiry.date}</p>
      </div>

      <table style="width:100%;border-collapse:collapse;margin-bottom:20px;">
        <tr>
          <td style="padding:10px 12px;background:#FAF6EE;font-weight:600;color:#4A000B;width:30%;border:1px solid #EFE4D0;">Devotee Name</td>
          <td style="padding:10px 12px;border:1px solid #EFE4D0;color:#222222;font-weight:700;">${enquiry.name}</td>
        </tr>
        <tr>
          <td style="padding:10px 12px;background:#FAF6EE;font-weight:600;color:#4A000B;border:1px solid #EFE4D0;">Phone Number</td>
          <td style="padding:10px 12px;border:1px solid #EFE4D0;color:#222222;">
            ${enquiry.phone.isNotEmpty ? '<a href="tel:${enquiry.phone}" style="color:#C5A059;text-decoration:none;font-weight:600;">${enquiry.phone}</a>' : 'Not provided'}
          </td>
        </tr>
        <tr>
          <td style="padding:10px 12px;background:#FAF6EE;font-weight:600;color:#4A000B;border:1px solid #EFE4D0;">Email Address</td>
          <td style="padding:10px 12px;border:1px solid #EFE4D0;color:#222222;">
            ${enquiry.email.isNotEmpty ? '<a href="mailto:${enquiry.email}" style="color:#C5A059;text-decoration:none;font-weight:600;">${enquiry.email}</a>' : 'Not provided'}
          </td>
        </tr>
      </table>

      <h3 style="color:#4A000B;font-size:14px;margin:0 0 8px 0;letter-spacing:0.5px;">DEVOTEE MESSAGE / PRAYER REQUEST:</h3>
      <div style="background:#FAF8F3;border:1px solid #E2D3B8;border-radius:10px;padding:16px;color:#222222;font-size:14px;line-height:1.6;margin-bottom:24px;">
        ${enquiry.message}
      </div>

      ${enquiry.email.isNotEmpty ? '''
      <div style="text-align:center;margin-bottom:16px;">
        <a href="mailto:${enquiry.email}?subject=Pranam ${enquiry.name} ji — Shree Pavan Putra Garbi Mandal" style="display:inline-block;background-color:#4A000B;color:#FFFFFF;padding:12px 24px;border-radius:8px;text-decoration:none;font-weight:700;font-size:13px;border:1px solid #C5A059;">Reply to ${enquiry.name}</a>
      </div>
      ''' : ''}
    </div>

    <div style="background:#FAF6EE;padding:14px 20px;text-align:center;border-top:1px solid #E8DCBF;color:#666666;font-size:11px;">
      <p style="margin:0 0 4px 0;font-weight:600;color:#7A5812;">|| જાગતી જોગમાયા || || જય માતાજી ||</p>
      <p style="margin:0;">Shree Pavan Putra Garbi Mandal Trust, Rajkot • Notification routed to $recipientEmail</p>
    </div>
  </div>
</body>
</html>
''';
  }

  String _buildTestHtml({required AdminNotificationEmail recipient, required String timestamp}) {
    return '''
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"></head>
<body style="margin:0;padding:24px;background-color:#FAF6EE;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;">
  <div style="max-width:560px;margin:0 auto;background:#FFFFFF;border-radius:12px;overflow:hidden;border:1.5px solid #C5A059;">
    <div style="background-color:#4A000B;padding:20px;text-align:center;border-bottom:3px solid #C5A059;">
      <h2 style="margin:0;color:#FFFFFF;font-size:20px;">✅ Notification System Active</h2>
      <p style="margin:4px 0 0 0;color:#F0D590;font-size:12px;">Shree Pavan Putra Garbi Mandal — Verification Mail</p>
    </div>
    <div style="padding:24px;color:#333;">
      <p style="font-size:14px;">Pranam <strong>${recipient.recipientName}</strong>,</p>
      <p style="font-size:13px;line-height:1.5;">Your administrative email address (<strong>${recipient.email}</strong>) has been successfully verified in the administration portal for the <strong>${recipient.department}</strong> department.</p>
      <div style="background:#E8F5E9;border:1px solid #81C784;border-radius:8px;padding:12px;margin:16px 0;font-size:12px;color:#2E7D32;font-weight:600;">
        ✓ Real-time notifications are enabled. Whenever citizens submit inquiries on the public Contact page, you will receive full details immediately.
      </div>
      <p style="font-size:11.5px;color:#888;">Verification Timestamp: $timestamp</p>
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
    return '''
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"></head>
<body style="margin:0;padding:24px;background-color:#FAF6EE;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;">
  <div style="max-width:600px;margin:0 auto;background:#FFFFFF;border-radius:14px;overflow:hidden;border:1.5px solid #C5A059;">
    <div style="background-color:#4A000B;padding:24px 20px;text-align:center;border-bottom:3px solid #C5A059;">
      <p style="margin:0 0 6px 0;color:#E6C875;font-size:13px;letter-spacing:1px;font-weight:600;">|| જય માતાજી || || જાગતી જોગમાયા ||</p>
      <h1 style="margin:0;color:#FFFFFF;font-size:22px;font-weight:700;">શ્રી પવન પુત્ર ગરબી મંડળ - રાજકોટ</h1>
      <p style="margin:4px 0 0 0;color:#F0D590;font-size:12px;">Shree Pavan Putra Garbi Mandal Trust</p>
    </div>
    <div style="padding:24px;">
      <p style="font-size:15px;color:#4A000B;font-weight:700;margin:0 0 12px 0;">Pranam ${enquiry.name} ji,</p>
      <div style="background:#FAF8F3;border:1px solid #E2D3B8;border-radius:10px;padding:16px;color:#222222;font-size:14px;line-height:1.6;margin-bottom:20px;">
        $replyMessage
      </div>
      <div style="border-top:1px solid #E8DCBF;padding-top:14px;font-size:12px;color:#666;">
        <p style="margin:0;font-weight:600;color:#4A000B;">Warm regards,</p>
        <p style="margin:2px 0;font-weight:700;color:#222;">$senderName</p>
        <p style="margin:0;color:#7A5812;">Shree Pavan Putra Garbi Mandal Trust, Rajkot</p>
        <p style="margin:2px 0 0 0;color:#888;">Email: $senderEmail</p>
      </div>
    </div>
  </div>
</body>
</html>
''';
  }
}
