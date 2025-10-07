
# Blueprint: Pokémon Turn-Based Game

## Overview

This document outlines the plan for creating a Pokémon turn-based game in Flutter. The application will feature dynamic data loading from the PokéAPI, an expanded roster of Pokémon, and an improved user interface.

## Features

*   **API Integration:** Pokémon data (names, sprites, stats, and moves) will be fetched dynamically from the [PokéAPI](https://pokeapi.co/).
*   **Expanded Pokémon Roster:** The game will randomly select from the first 151 Pokémon for each battle, providing variety.
*   **Turn-based Combat:** Players can choose a move, and the opponent will retaliate. The game logic calculates damage and determines a winner.
*   **Health Bars:** Visual representation of each Pokémon's remaining health with improved styling.
*   **Enhanced UI/UX:**
    *   A more polished and visually appealing battle screen.
    *   Improved layout and styling using modern design principles.
    *   Custom fonts via `google_fonts` for better typography.
    *   Animations to provide feedback during combat (e.g., a shake animation on taking damage).
*   **State Management:** Use `FutureBuilder` to handle asynchronous data loading gracefully, showing a loading state to the user.

## Plan

1.  **Project Setup:**
    *   Add `http` for API calls and `google_fonts` for typography to `pubspec.yaml`.
    *   Create a service layer (`pokemon_service.dart`) to abstract the PokéAPI calls.
    *   Refactor data models (`Pokemon`, `Move`) to support JSON deserialization from the API response.

2.  **Game Screen (`battle_screen.dart`):**
    *   Use a `FutureBuilder` to fetch two random Pokémon at the start of the battle and display a loading indicator.
    *   Redesign the UI for a more modern and clean aesthetic.
    *   Implement a shake animation for when a Pokémon is hit.
    *   Style the Pokémon info cards, health bars, and move buttons.

3.  **Game Logic:**
    *   Update the `_startBattle` process to use the Pokémon fetched by the `PokemonService`.
    *   Ensure the turn-based system and damage calculation work correctly with the dynamically loaded data.

4.  **Polish and Refine:**
    *   Ensure the UI is responsive and looks good on different screen sizes.
    *   Test the application thoroughly to find and fix any bugs related to API calls or game logic.
