import { sendSupportEmail } from '../services/emailService.js';

// Handle support/contact form submission
export async function submitContactRequest(req, res, next) {
  try {
    const { name, email, requestType, message } = req.body;

    // Validate required fields
    if (!name || !email || !message) {
      return res.status(400).json({
        success: false,
        error: 'Missing required fields: name, email, and message are required',
      });
    }

    // Basic email validation
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return res.status(400).json({
        success: false,
        error: 'Invalid email address format',
      });
    }

    // Send the email
    const result = await sendSupportEmail({
      senderName: name,
      senderEmail: email,
      requestType: requestType || 'General Inquiry',
      message,
    });

    res.status(200).json({
      success: true,
      message: 'Support request sent successfully',
      data: {
        id: result.id,
      },
    });
  } catch (error) {
    console.error('Contact request error:', error);
    
    // Handle specific Resend errors
    if (error.message.includes('API key')) {
      return res.status(500).json({
        success: false,
        error: 'Email service not properly configured',
      });
    }

    res.status(500).json({
      success: false,
      error: error.message || 'Failed to send support request',
    });
  }
}

export default {
  submitContactRequest,
};
