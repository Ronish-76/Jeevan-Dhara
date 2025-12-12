# Jeevan Dhara – Blood Donation Management System

**Jeevan Dhara** is a cross-platform mobile application built with **Flutter**, designed to connect blood donors, requesters, hospitals, and blood banks in real time. The system streamlines blood donation processes, emergency requests, stock management, and donor verification—ensuring faster access to life-saving blood during critical situations.

---

## 📌 Key Features Overview

### **1. Requester (Patients & Families)**

* Post emergency or scheduled blood requests
* Search for compatible nearby donors
* Track request progress in real time
* Receive instant alerts when a donor accepts the request

### **2. Donor**

* Create and manage donor profile
* View compatible blood requests
* Accept donation requests
* Track donation history
* Automatic donation eligibility checks

### **3. Hospital**

* Maintain internal blood inventory
* Request blood from donors or blood banks
* Verify donor information and confirm donations
* Broadcast emergency blood shortages

### **4. Blood Bank**

* Full blood stock management
* Distribute blood to hospitals or requesters
* Record and organize donation drives
* Access analytics dashboards for inventory and usage insights

---

## 🛠️ Tech Stack

* **Frontend:** Flutter (Dart)
* **Backend:** Node.js + Express.js
* **Database:** MongoDB (Atlas or Local)
* **API Tunneling for Mobile:** NGROK
* **Authentication:** JWT (JSON Web Tokens)

---

## 📱 Project Setup Guide

### **Prerequisites**

* Flutter SDK installed
* Node.js + npm installed
* MongoDB installed or cloud DB created
* NGROK installed → [https://ngrok.com/download](https://ngrok.com/download)

---

## 🚀 Installation & Run Instructions

### **1. Clone the Repository**

```bash
git clone <repository-url>
cd jeevandhara
```

### **2. Backend Setup**

```bash
cd Backend
npm install
```

Create a `.env` file inside `/Backend`:

```
MONGO_URI=your_mongo_db_connection
JWT_SECRET=your_jwt_secret
PORT=5000
```

Start the backend:

```bash
npm start
```

---

### **3. Setup NGROK for Mobile App Connectivity**

Open a new terminal and run:

```bash
ngrok http 5000
```

Copy the **Forwarding URL** (e.g., `https://abc123.ngrok.io`).

Update it inside your Flutter app (`api_config.dart` or equivalent).

---

### **4. Flutter App Setup**

```bash
cd ..
flutter pub get
flutter run
```

---

## 📌 Project Structure Overview

```
JeevanDhara/
│
├── Backend/
│   ├── controllers/
│   ├── models/
│   ├── routes/
│   ├── utils/
│   ├── server.js
│   └── .env
│
├── lib/
│   ├── screens/
│   ├── widgets/
│   ├── services/
│   ├── models/
│   ├── utils/
│   └── main.dart
│
├── assets/
│   ├── icons/
│   └── images/
│
└── README.md
```

---

## 🤝 Contribution

Contributions are welcome!
Feel free to open issues, suggest improvements, or submit pull requests.

---

## 📄 License

This project is licensed under the **MIT License**.
