const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

admin.initializeApp();

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "dhanushmd777@gmail.com",
    pass: "zbep gyvd diuy hxre",
  },
});

exports.sendTaskEmail = onDocumentCreated("tasks/{taskId}", async (event) => {
  const task = event.data.data();

  const userDoc = await admin
      .firestore()
      .collection("users")
      .doc(task.userId)
      .get();

  const email = userDoc.data().email;

  if (!email) return null;

  // Convert Firestore Timestamp → readable date
  let dueDate = "No due date";

  if (task.dueDate) {
    const date = task.dueDate.toDate();
    dueDate = date.toLocaleString("en-IN", {
      dateStyle: "medium",
      timeStyle: "short",
    });
  }

  const mailOptions = {
    from: "\"Hemody Task Manager\" <dhanushmd777@gmail.com>",
    to: email,
    subject: "📌 New Task Added - Hemody",
    html: `
      <div style="font-family: Arial, sans-serif; padding:20px; background:#f4f6f8">
        
        <div style="max-width:600px; margin:auto; background:white; border-radius:10px; padding:20px; box-shadow:0 4px 10px rgba(0,0,0,0.1)">
          
          <h2 style="color:#4A6CF7;">📋 New Task Added</h2>

          <p>Hello,</p>

          <p>A new task has been added to your <b>Hemody Task Manager</b>.</p>

          <hr/>

          <p><b>📝 Title:</b> ${task.title}</p>
          <p><b>📄 Description:</b> ${task.description}</p>
          <p><b>⏰ Due Date:</b> ${dueDate}</p>

          <hr/>

          <p style="color:#666">
            Stay productive and complete your task on time 🚀
          </p>

          <p style="margin-top:30px; font-size:14px; color:#999">
            Added by <b>Hemody</b><br>
            Developed by Dhanush
          </p>

        </div>

      </div>
    `,
  };

  return transporter.sendMail(mailOptions);
});
