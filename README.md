# 📋 Hemody Task Manager

Hemody Task Manager is a **Flutter + Firebase task management application** that allows users to manage daily tasks with **secure OTP authentication, real-time updates, and automated email notifications**.

---

# 🚀 Features

### 🔐 Phone OTP Authentication
- Secure login using **Firebase Phone Authentication**
- OTP verification for user login
- Automatic session management
- Logout functionality

---

### ✅ Task Management
Users can:

- ➕ Add new tasks
- 📝 Add task **description**
- 📅 Set **due date and time**
- ✏ Edit existing tasks
- ✔ Mark tasks as **completed**
- ❌ Delete tasks
- 🔄 View tasks in real-time (Firestore)

---

### 📧 Email Notifications
When a user adds a task:

- A **Firebase Cloud Function triggers automatically**
- An **email notification is sent to the user's saved email**

Email contains:

- Task Title
- Task Description
- Due Date & Time
- Hemody branding

---

# 🛠 Tech Stack

| Technology | Purpose |
|------------|--------|
Flutter | Mobile App Development |
Firebase Authentication | OTP Login |
Cloud Firestore | Database |
Firebase Cloud Functions | Email trigger |
Nodemailer | Sending email |
GitHub | Version control |

---

# 📱 App Screenshots
## Onboarding Screen
![Login](images/on.jpg)

## Login Screen
![Login](images/lo.jpg)

## OTP Verification
![OTP](screenshots/otp.png)

## Home Screen
![Home](screenshots/home.png)

## Add Task
![Add Task](screenshots/add_task.png)

## Profile Screen
![Profile](screenshots/profile.png)

---

# 🧠 Application Architecture
