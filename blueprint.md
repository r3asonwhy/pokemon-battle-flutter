# Blueprint: Pokémon Battle App

## Overview

This document outlines the design and architecture of a simple Pokémon battle simulator built with Flutter. The application will fetch Pokémon data from an external API and allow users to engage in a turn-based battle.

## Features

*   **API Integration:** Pokémon data (names, sprites, stats, and moves) will be fetched dynamically from the [PokéAPI](https://pokeapi.co/).
*   **Expanded Pokémon Roster:** The game will randomly select from the first 151 Pokémon for each battle, providing variety.
*   **Turn-based Combat:** Players can choose between a simple attack and a special move. The game logic calculates damage and determines a winner.
*   **Health Bars:** Visual representation of each Pokémon's remaining health with improved styling.
*   **Enhanced UI/UX:**
    *   A more polished and visually appealing battle screen.
    *   Improved layout and styling using modern design principles.
    *   Clear indication of the player's Pokémon.
    *   Beautifully styled attack buttons with gradients, icons, and shadows.
    *   **Dynamic Battle Log:** A beautifully styled and animated text box to display battle messages.
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
    *   Add a label to clearly identify the player's Pokémon.
    *   Style the Pokémon info cards, health bars, and move buttons.
    *   Style and animate the battle message display.
    *   Implement a shake animation for when a Pokémon is hit.

3.  **Game Logic:**
    *   Update the `_startBattle` process to use the Pokémon fetched by the `PokemonService`.
    *   Implement two distinct attack buttons: a standard "Tackle" and a "Special Attack" fetched from the API.
    *   Ensure the turn-based system and damage calculation work correctly with the dynamically loaded data.