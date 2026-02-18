# VU document template for Typst

Configuration is usualy stored inside `config` folder, but some structural requirements are fulfilled in main document files.

## Layout/design requirement checklist

| **Id** | **Requirement**                         | **Source, location**                                  | **Optional** | **Status** | **Config location**                                                     |
| ------ | --------------------------------------- | ----------------------------------------------------- | ------------ | ---------- | ----------------------------------------------------------------------- |
| R1     | Column count                            | [Final thesis reqs][1]. Section 5. 2nd B.P.           | No           | Done       | `config/base/page.typ`                                                  |
| R2     | Margins                                 | [Final thesis reqs][1]. Section 5. 3rd B.P.           | No           | Done       | `config/base/page.typ`                                                  |
| R3.1   | Typeface                                | [Final thesis reqs][1]. Section 5. 4th B.P.           | No           | Done       | `config/base/text.typ`                                                  |
| R3.2   | Main text font size                     | [Final thesis reqs][1]. Section 5. 4th B.P.           | No           | Done       | `config/base/text.typ`                                                  |
| R3.3   | Main text font style & weight           | [Final thesis reqs][1]. Section 5. 4th B.P.           | No           | Done       | `config/base/text.typ`                                                  |
| R3.4   | Title & heading font weights            | [Final thesis reqs][1]. Section 5. 4th B.P.           | Yes          | Done       | `config/blocks/headings.typ`                                            |
| R3.5   | Title & heading font sizes              | [Final thesis reqs][1]. Section 5. 4th B.P.           | Yes          | Done       | `config/blocks/headings.typ`                                            |
| R3.6   | Font size on figure and table captions  | [Final thesis reqs][1]. Section 5. 4th B.P.           | Yes          | Missing    |                                                                         |
| R4     | Line spacing                            | [Final thesis reqs][1]. Section 5. 5th B.P.           | No           | Done       | `config/base/par.typ`, `config/blocks/headings.typ`                     |
| R5     | Page numering                           | [Final thesis reqs][1]. Section 5. 6th B.P.           | No           | Done       | `config/base/page.typ`                                                  |
| R6     | Section order                           | [Final thesis reqs][1]. Section 5. 7th B.P.           | No           | Done       | `thesis.typ`                                                            |
| R7     | Declaration of meetings with supervisor | [Final thesis reqs][1]. Section 5. 8th B.P.           | No           | Done       | `supervisor-declaration.typ`                                            |
| R8     | Bibliography                            | [Final thesis reqs][1]. Section 5. 9th B.P.           | No           | Done       | `config/objects/bibliography.typ`                                       |
| R9.1   | Section numbering                       | [Final thesis reqs][1]. Section 5. Last par.          | No           | Done       | `config/blocks/headings.typ`                                            |
| R9.2   | Which sections are numbered             | [Final thesis reqs][1]. Section 5. Last par.          | No           | Done       | Each section explicitly configures whether heading enumeration is shown |
| R9.3   | Appendix numbering                      | [Final thesis reqs][1]. Section 5. Last par.          | No           | Done       | `backmatter/appendices.typ`                                             |
| R10    | Figure caption location                 | [Written assignment reqs][2]. Section 1.1.1. 1st par. | No           | Done       | ``                                                                        |
|        |                                         |                                                       |              |            |                                                                         |
|        |                                         |                                                       |              |            |                                                                         |
|        |                                         |                                                       |              |            |                                                                         |

[1]: <https://mif.vu.lt/lt3/dokumentai/dokumentai/KOMP/Reglamentuojantys/Reikalavimai_Magistriniams_Darbams.pdf> "Requirements for final theses"
[2]: <https://mif.vu.lt/lt3/dokumentai/dokumentai/KOMP/Reglamentuojantys/Metodine_medziaga.pdf> "Requirements and recommendations for written assignments"