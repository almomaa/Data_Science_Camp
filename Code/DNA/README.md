# DNA & Hamming Distance — teaching scripts

A short MATLAB unit for school students: DNA is just a 4-letter text, and
**Hamming distance** (the number of positions where two equal-length
sequences differ) is how we compare and search it.

Run the scripts in order. Each is self-contained, has a story at the top,
a few knobs to change, and a "THINGS TO TRY" section at the bottom.

| # | File | Big idea |
|---|------|----------|
| 1 | `dna1_spot_the_difference.m` | What Hamming distance *is*: line up two sequences, count the mismatches. |
| 2 | `dna2_who_am_i.m` | **Searching a database.** Identify a mystery sample by its closest match (real "DNA barcoding"). Genetic distance mirrors the tree of life. |
| 3 | `dna3_sickle_cell.m` | **One letter matters.** A single base change (Hamming distance 1) causes sickle cell anemia. Includes DNA→protein translation. |
| 4 | `dna4_molecular_clock.m` | **Mutations pile up over time.** Distance grows with generations — how we date species splits and track virus variants. |
| 5 | `dna5_hamming_limit.m` | **Where Hamming breaks.** One inserted letter ruins the naive count — motivates sequence alignment / edit distance / BLAST. |

## Shared helper functions (used by the scripts)

- `hammingDistance.m` — counts differing positions; refuses unequal lengths (on purpose — that's the lesson of script 5).
- `showAlignment.m` — draws two sequences stacked with mismatches highlighted in red and the Hamming distance in the title.

## Suggested flow (about the second half of a session)

1. Warm up with **script 1** — have students spot the differences by eye first, then let the computer count.
2. **Script 2** is the centerpiece — the "who is the mystery DNA?" reveal.
3. **Script 3** is the emotional punch — distance of 1, a whole disease.
4. **Scripts 4 and 5** are stretch material: the molecular clock, and the honest limitation that leads to real-world tools like BLAST.
