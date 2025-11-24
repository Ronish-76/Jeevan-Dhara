
 # jeevandhara
 # Jeevan Dhara - Blood Donation Management System

 A new Flutter project.
 **Jeevan Dhara** is a comprehensive blood donation platform designed to bridge the gap between blood donors, hospitals, blood banks, and requesters. It facilitates real-time coordination for blood requests, donations, and inventory management to save lives efficiently.

 ## Getting Started
 ## 🚀 Features

 This project is a starting point for a Flutter application.
 The application caters to four distinct user roles, each with tailored functionalities:

 A few resources to get you started if this is your first Flutter project:
 ### 1. **Requester (Patient/Family)**
 - **Post Blood Requests:** Create emergency or scheduled blood requests.
 - **Find Donors:** Search for nearby compatible donors.
 - **Track Status:** Monitor the status of blood requests in real-time.
 - **Notifications:** Receive alerts when a donor accepts a request.

 - [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
 - [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
 ### 2. **Donor**
 - **Register & Profile:** maintain a donor profile with blood group and health status.
 - **View Requests:** Browse nearby blood requests compatible with your blood type.
 - **Donate:** Accept requests and track donation history.
 - **Eligibility Check:** Automated checks for donation eligibility based on last donation date.

 For help getting started with Flutter development, view the
 [online documentation](https://docs.flutter.dev/), which offers tutorials,
 samples, guidance on mobile development, and a full API reference.
 ### 3. **Hospital**
 - **Inventory Management:** Track internal blood stock levels.
 - **Request Blood:** Place bulk or specific requests to blood banks.
 - **Verify Donors:** Validate donor information and record donations.
 - **Emergency Alerts:** Broadcast emergency requirements to nearby donors and blood banks.
​
 ### 4. **Blood Bank**
 - **Stock Management:** comprehensive inventory tracking for all blood groups.
 - **Distribute Blood:** Manage blood distribution to hospitals and requesters.
 - **Organize Drives:** Schedule and manage blood donation drives.
 - **Analytics:** View reports on donation trends and inventory status.
​
 ## 🛠️ Tech Stack
​
 - **Frontend:** [Flutter](https://flutter.dev/) (Dart) - Cross-platform mobile application.
 - **Backend:** [Node.js](https://nodejs.org/) with [Express.js](https://expressjs.com/).
 - **Database:** [MongoDB](https://www.mongodb.com/) - NoSQL database for storing user and transaction data.
 - **Authentication:** JWT (JSON Web Tokens) for secure user sessions.
​
 ## 📱 Getting Started
​
 ### Prerequisites
 - [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
 - [Node.js](https://nodejs.org/) and npm installed.
 - [MongoDB](https://www.mongodb.com/) instance (local or Atlas) running.
​
 ### Installation
​
 1.  **Clone the repository:**
     ```bash
     git clone <repository-url>
     cd jeevandhara
     ```
​
 2.  **Setup Backend:**
     - Navigate to the backend directory:
       ```bash
       cd Backend
       ```
     - Install dependencies:
       ```bash
       npm install
       ```
     - Create a `.env` file in the `Backend` folder and configure your environment variables (MongoDB URI, JWT Secret, etc.).
     - Start the server:
       ```bash
       npm start
       ```
​
 3.  **Setup Frontend (Flutter):**
     - Navigate back to the root directory:
       ```bash
       cd ..
       ```
     - Install Flutter dependencies:
       ```bash
       flutter pub get
       ```
     - Run the app:
       ```bash
       flutter run
       ```
​
 ## 🤝 Contribution
​
 Contributions are welcome! Please feel free to submit a Pull Request.
​
 ## 📄 License
​
 This project is licensed under the MIT License.Read README.md
