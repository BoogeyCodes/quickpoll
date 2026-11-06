# Changelog

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added
- `Poll#leading_option` — the option currently in the lead, or `nil` when there are no
  votes or a tie for first.

## [0.1.0]

### Added
- Polls API: create polls with options, vote once per voter token, live results.
- One-vote-per-voter via validation and a unique DB index; JSON error contract.
