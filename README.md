# Portimonense SC Historical Database

This repository contains a structured SQL database designed to archive and analyze the competitive history of **Portimonense Sporting Clube**. From the historical regional Algarve leagues to the heights of the Primeira Liga, this schema captures every goal, match, and managerial era.

> **⚠️ Project Status:** This is an **ongoing project**. While the core architecture and team-level data structures are almost finalized, the `players` and `player_performance` tables are currently placeholders and remain empty as data collection continues.

---

## Database Architecture

The database is structured as a **Galaxy Schema**. This design is highly efficient for sports analytics because it supports two different levels of "grain" through two central Fact tables:

### 1. Fact Tables
* **`matches`**: The "Team-Level" fact table. It stores match results, opponents, and venue details.
* **`player_performance`**: The "Player-Level" fact table. It tracks individual contributions (goals, cards, minutes) linked to each match.

### 2. Dimension Tables
* **`seasons`**: Defines the timeframe (e.g., "2023/2024").
* **`competitions`**: Categorizes matches (Liga Portugal, Taça de Portugal, etc.).
* **`managers`**: Attributes match data to specific coaching eras.
* **`players`**: The master directory for every player who has worn the black and white stripes.

---

## Schema Visualization

The relationship flow follows this logic:
* **Manager Performance:** `managers` ↔ `matches`
* **Season Stats:** `seasons` ↔ `matches`
* **Individual Stats:** `players` ↔ `player_performance` ↔ `matches`

---

## Getting Started

### Prerequisites

    MySQL 8.0+.

    A SQL client. I used MySQL Workbench.

### Installation

   Using a GUI (Workbench):

    Create a new database named portimonense_db.

    Open the portimonense_dump.sql file.

    Execute the script to populate the tables.

---

## License

This project is open-source and intended for Portimonense fans and data enthusiasts.
