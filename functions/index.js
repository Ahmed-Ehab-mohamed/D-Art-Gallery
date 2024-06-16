const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

// Initialize Firebase Admin SDK
admin.initializeApp();

// Initialize Nodemailer for sending emails
const transporter = nodemailer.createTransport({
  service: "Gmail", // Use your email service provider
  auth: {
    user: functions.config().email.user,
    pass: functions.config().email.pass,
  },
});

// Cloud Function to send verification code via email
exports.sendVerificationCode = functions.https.onCall(async (data, context) => {
  try {
    const email = data.email;
    const code = Math.floor(100000 + Math.random() * 900000).toString();

    // Save the code to Firestore for later verification
    await admin.firestore()
        .collection("verificationCodes")
        .doc(email)
        .set({code});

    // Send the verification code via email
    const mailOptions = {
      from: functions.config().email.user,
      to: email,
      subject: "Your Verification Code",
      text: `Your verification code is ${code}`,
    };

    await transporter.sendMail(mailOptions);
    return {success: true};
  } catch (error) {
    console.error("Error sending email:", error);
    return {success: false, error: error.message};
  }
});

// Cloud Function to verify the verification code
exports.verifyCode = functions.https.onCall(async (data, context) => {
  try {
    const email = data.email;
    const code = data.code;

    // Retrieve the verification code from Firestore
    const doc = await admin.firestore()
        .collection("verificationCodes")
        .doc(email)
        .get();

    // Check if the code matches
    if (!doc.exists || doc.data().code !== code) {
      return {success: false, message: "Invalid code"};
    }

    // Code verified, perform further actions (e.g., reset password)
    return {success: true};
  } catch (error) {
    console.error("Error verifying code:", error);
    return {success: false, error: error.message};
  }
});
