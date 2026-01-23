import { Resend } from 'resend';

// Initialize Resend client
const resend = new Resend(process.env.RESEND_API_KEY);

// Generate BedFlow-themed HTML email template for support requests
const generateSupportEmailTemplate = ({ senderName, senderEmail, requestType, message, receivedDate }) => {
  return `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>BedFlow Support Request</title>
</head>
<body style="margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; background-color: #f0f4f8;">
  <table role="presentation" style="width: 100%; border-collapse: collapse;">
    <tr>
      <td align="center" style="padding: 40px 20px;">
        <table role="presentation" style="width: 100%; max-width: 600px; border-collapse: collapse; background: #ffffff; border-radius: 16px; box-shadow: 0 4px 24px rgba(0, 0, 0, 0.08);">
          
          <!-- Header with gradient -->
          <tr>
            <td style="background: linear-gradient(135deg, #0077B6 0%, #0096C7 50%, #00B4D8 100%); padding: 32px 40px; border-radius: 16px 16px 0 0;">
              <table role="presentation" style="width: 100%; border-collapse: collapse;">
                <tr>
                  <td>
                    <table role="presentation" style="border-collapse: collapse;">
                      <tr>
                        <td style="background: rgba(255, 255, 255, 0.2); border-radius: 12px; padding: 12px; vertical-align: middle;">
                          <img src="https://api.iconify.design/lucide:bed.svg?color=white" alt="BedFlow" width="28" height="28" style="display: block;" />
                        </td>
                        <td style="padding-left: 16px; vertical-align: middle;">
                          <h1 style="margin: 0; font-size: 24px; font-weight: 700; color: #ffffff; letter-spacing: -0.02em;">BedFlow</h1>
                          <p style="margin: 4px 0 0; font-size: 13px; color: rgba(255, 255, 255, 0.9);">Hospital Bed Management System</p>
                        </td>
                      </tr>
                    </table>
                  </td>
                  <td align="right" style="vertical-align: top;">
                    <span style="display: inline-block; background: rgba(255, 255, 255, 0.2); color: #ffffff; font-size: 12px; font-weight: 600; padding: 6px 12px; border-radius: 20px; text-transform: uppercase; letter-spacing: 0.5px;">
                      ${requestType || 'Support Request'}
                    </span>
                  </td>
                </tr>
              </table>
            </td>
          </tr>

          <!-- Alert Banner -->
          <tr>
            <td style="background: linear-gradient(90deg, #FF6B35 0%, #F7931E 100%); padding: 16px 40px;">
              <table role="presentation" style="width: 100%; border-collapse: collapse;">
                <tr>
                  <td style="vertical-align: middle;">
                    <img src="https://api.iconify.design/lucide:alert-circle.svg?color=white" alt="Alert" width="20" height="20" style="display: inline-block; vertical-align: middle; margin-right: 12px;" />
                    <span style="color: #ffffff; font-size: 14px; font-weight: 600;">New Support Request Received</span>
                  </td>
                  <td align="right">
                    <span style="color: rgba(255, 255, 255, 0.9); font-size: 12px;">${receivedDate}</span>
                  </td>
                </tr>
              </table>
            </td>
          </tr>

          <!-- Main Content -->
          <tr>
            <td style="padding: 40px;">
              
              <!-- User Info Card -->
              <table role="presentation" style="width: 100%; border-collapse: collapse; background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%); border-radius: 12px; margin-bottom: 24px;">
                <tr>
                  <td style="padding: 24px;">
                    <h2 style="margin: 0 0 16px; font-size: 14px; font-weight: 600; color: #64748b; text-transform: uppercase; letter-spacing: 0.5px;">
                      <img src="https://api.iconify.design/lucide:user.svg?color=%2364748b" alt="" width="14" height="14" style="display: inline-block; vertical-align: middle; margin-right: 8px;" />
                      Contact Information
                    </h2>
                    <table role="presentation" style="width: 100%; border-collapse: collapse;">
                      <tr>
                        <td style="padding: 8px 0; border-bottom: 1px solid #e2e8f0;">
                          <span style="font-size: 12px; color: #94a3b8; display: block;">Name</span>
                          <span style="font-size: 16px; color: #1e293b; font-weight: 500;">${senderName}</span>
                        </td>
                      </tr>
                      <tr>
                        <td style="padding: 8px 0;">
                          <span style="font-size: 12px; color: #94a3b8; display: block;">Email Address</span>
                          <a href="mailto:${senderEmail}" style="font-size: 16px; color: #0077B6; font-weight: 500; text-decoration: none;">${senderEmail}</a>
                        </td>
                      </tr>
                    </table>
                  </td>
                </tr>
              </table>

              <!-- Message Card -->
              <table role="presentation" style="width: 100%; border-collapse: collapse; background: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px;">
                <tr>
                  <td style="padding: 24px;">
                    <h2 style="margin: 0 0 16px; font-size: 14px; font-weight: 600; color: #64748b; text-transform: uppercase; letter-spacing: 0.5px;">
                      <img src="https://api.iconify.design/lucide:message-square.svg?color=%2364748b" alt="" width="14" height="14" style="display: inline-block; vertical-align: middle; margin-right: 8px;" />
                      Message
                    </h2>
                    <div style="font-size: 15px; line-height: 1.7; color: #334155; background: #f8fafc; padding: 20px; border-radius: 8px; border-left: 4px solid #0077B6;">
                      ${message.replace(/\n/g, '<br>')}
                    </div>
                  </td>
                </tr>
              </table>

              <!-- Action Button -->
              <table role="presentation" style="width: 100%; border-collapse: collapse; margin-top: 32px;">
                <tr>
                  <td align="center">
                    <a href="mailto:${senderEmail}?subject=Re: Your BedFlow Support Request" style="display: inline-block; background: linear-gradient(135deg, #0077B6 0%, #0096C7 100%); color: #ffffff; font-size: 14px; font-weight: 600; text-decoration: none; padding: 14px 32px; border-radius: 8px; box-shadow: 0 4px 12px rgba(0, 119, 182, 0.3);">
                      <img src="https://api.iconify.design/lucide:reply.svg?color=white" alt="" width="16" height="16" style="display: inline-block; vertical-align: middle; margin-right: 8px;" />
                      Reply to User
                    </a>
                  </td>
                </tr>
              </table>

            </td>
          </tr>

          <!-- Footer -->
          <tr>
            <td style="background: #f8fafc; padding: 24px 40px; border-radius: 0 0 16px 16px; border-top: 1px solid #e2e8f0;">
              <table role="presentation" style="width: 100%; border-collapse: collapse;">
                <tr>
                  <td style="text-align: center;">
                    <p style="margin: 0 0 8px; font-size: 12px; color: #94a3b8;">
                      This email was sent from the BedFlow contact form
                    </p>
                    <p style="margin: 0; font-size: 11px; color: #cbd5e1;">
                      Ghana Health Service • Hospital Bed Management System
                    </p>
                  </td>
                </tr>
              </table>
            </td>
          </tr>

        </table>
      </td>
    </tr>
  </table>
</body>
</html>
  `;
};

// Send support request email
export async function sendSupportEmail({ senderName, senderEmail, requestType, message }) {
  const adminEmail = process.env.ADMIN_EMAIL || process.env.TESTMAIL_ADDRESS;
  
  if (!adminEmail) {
    throw new Error('Admin email not configured. Set ADMIN_EMAIL or TESTMAIL_ADDRESS in environment.');
  }

  if (!process.env.RESEND_API_KEY) {
    throw new Error('RESEND_API_KEY not configured in environment.');
  }

  const receivedDate = new Date().toLocaleDateString('en-GB', {
    weekday: 'long',
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  });

  const htmlContent = generateSupportEmailTemplate({
    senderName,
    senderEmail,
    requestType,
    message,
    receivedDate,
  });

  const { data, error } = await resend.emails.send({
    from: 'BedFlow Support <onboarding@resend.dev>',
    to: [adminEmail],
    subject: `[BedFlow Support] ${requestType || 'New Request'} from ${senderName}`,
    replyTo: senderEmail,
    html: htmlContent,
  });

  if (error) {
    console.error('Resend API error:', error);
    throw new Error(error.message || 'Failed to send email');
  }

  return data;
}

export default {
  sendSupportEmail,
};
