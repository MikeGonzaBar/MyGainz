# MyGainz

**MyGainz** is an app designed to help you track your fitness progress. It guides you through authentication, exercise logging, routine management, and progress visualization to empower your personal fitness journey.

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [User Flows](#user-flows)
  - [Authentication & Registration](#authentication--registration)
  - [Main Home](#main-home)
  - [Exercises & Routines](#exercises--routines)
  - [Logging Workouts](#logging-workouts)
  - [Progress Tracking](#progress-tracking)
  - [Profile](#profile)
- [Technologies](#technologies)
- [Installation & Setup](#installation--setup)
- [Contribution Guidelines](#contribution-guidelines)
- [License](#license)
- [Future Roadmap](#future-roadmap)

---

## Overview

**MyGainz** is a Flutter-based fitness tracking application that leverages Firebase for backend services. It offers a seamless experience for tracking workouts, monitoring progress, and managing personal fitness routines with an intuitive interface designed in Figma.

---

## Features

- **Secure Authentication:** Options for Google and email/password login.
- **Dynamic Registration Flow:** Auto-detects first-time users to gather personal and fitness information.
- **Comprehensive Dashboard:** View recent exercises, routines, and essential metrics.
- **Custom Exercises & Routines:** Create, log, and manage personalized workouts.
- **Progress Visualizations:** Detailed graphs and trend analyses of fitness achievements.
- **Profile Management:** Access and download personal data along with visual insights on muscle focus.

---

## User Flows

### Authentication & Registration

- **Login Options:**
  - **Google Authentication:** Streamlined with pre-populated information.
  - **Email & Password:** Standard credential-based login.
- **First-Time Setup (Registration Page):**
  - **Personal Information:**
    - Name (if not provided by Google)
    - Last Name (if not provided by Google)
    - Birthday (if not provided by Google)
    - Profile Picture (if not provided by Google)
  - **Fitness Information:**
    - Height
    - Weight
    - Fat Percentage
    - Muscle Percentage

### Main Home

The main dashboard displays:
- Recent exercises
- Recent routines
- Current weight and height metrics

### Exercises & Routines

- **Exercises Menu:**
  - Contains a default list of exercises with the option to add custom exercises.
  - **Exercise Details:**
    - Name
    - Target Muscle(s)
    - Equipment used
- **Routine Creator:**
  - Set a name and add exercises.
  - The target muscles will be auto-calculated based on the included exercises.
  - Option to enforce a fixed or random exercise order.

### Logging Workouts

- **Log Page Functionality:**
  - The app prompts the user to log either a single exercise or a routine.
  - **For Exercises:**
    - A pop-up gathers details like equipment used, set count, reps per set, and weight per set.
  - **For Routines:**
    - If using a random order, the user selects the next exercise to perform.
    - The current routine continues until the user indicates it is complete.

### Progress Tracking

- **Progress Page:**
  - Users select a time range (e.g., all time, last 6 months, last month).
  - A toggle allows users to display overall improvement by muscle group in a spider graph.
  - Selecting a muscle group allows for further filtering by specific exercises.
  - A line/bar graph then shows performance per equipment type (e.g., dumbbells, various weighted bars, machines, cables).

### Profile

- **Profile Page Displays:**
  - Name and Last Name
  - Email used for registration
  - Profile picture
  - Weight and height metrics
  - A graph showing the distribution and focus on different muscle groups
  - An option to download personal data

---

## Technologies

- **Design:**  
  - [Figma (UI/UX design)](https://www.figma.com/design/y15owMIsmAJmE2iHz4hMHr/My-Gainz?node-id=4-2&t=QQyG22n5uUXpoAJl-1)
  - flaticon.com for free icons

- **App Development:**  
  - Flutter (cross-platform mobile app development)

- **Backend & Database:**  
  - Firebase

---

## Installation & Setup

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/yourusername/MyGainz.git
   cd MyGainz
2. **Install dependencies:**
    flutter pub get
3. **Configure Firebase:**
    Follow the [Firebase setup instructions](https://firebase.google.com/docs/flutter/setup?platform=ios) to configure your Firebase project.
4. **Run the app**
    ```bash
    flutter run
    ```
