# VU document template for Typst

Configuration is usualy stored inside `config` folder, but some structural requirements are fulfilled in main document files.

## Layout/design requirement checklist

| **Id** | **Requirement**                         | **Source, location**           | **Optional** | **Status** | **Config location**               |
| ------ | --------------------------------------- | ------------------------------ | ------------ | ---------- | --------------------------------- |
| R1     | Column count                            | [Reqs][1]. Section 5. 2nd B.P. | No           | Done       | `config/base/page.typ`            |
| R2     | Margins                                 | [Reqs][1]. Section 5. 3rd B.P. | No           | Done       | `config/base/page.typ`            |
| R3.1   | Typeface                                | [Reqs][1]. Section 5. 4th B.P. | No           | Done       | `config/base/text.typ`            |
| R3.2   | Main text font size                     | [Reqs][1]. Section 5. 4th B.P. | No           | Done       | `config/base/text.typ`            |
| R3.3   | Main text font style & weight           | [Reqs][1]. Section 5. 4th B.P. | No           | Done       | `config/base/text.typ`            |
| R3.4   | Title & heading font weights            | [Reqs][1]. Section 5. 4th B.P. | Yes          | Done       | `config/blocks/headings.typ`      |
| R3.5   | Title & heading font sizes              | [Reqs][1]. Section 5. 4th B.P. | Yes          | Done       | `config/blocks/headings.typ`      |
| R3.6   | Font size on figure and table captions  | [Reqs][1]. Section 5. 4th B.P. | Yes          | Missing    |                                   |
| R4     | Line spacing                            | [Reqs][1]. Section 5. 5th B.P. | No           | Done       | `config/base/par.typ`             |
| R5     | Page numering                           | [Reqs][1]. Section 5. 6th B.P. | No           | Done       | `config/base/page.typ`            |
| R6     | Section order                           | [Reqs][1]. Section 5. 7th B.P. | No           | Done       | `thesis.typ`                      |
| R7     | Declaration of meetings with supervisor | [Reqs][1]. Section 5. 8th B.P. | No           | Done       | `supervisor-declaration.typ`      |
| R8     | Bibliography                            | [Reqs][1]. Section 5. 9th B.P. | No           | Done       | `config/objects/bibliography.typ` |
|        |                                         |                                |              |            |                                   |
|        |                                         |                                |              |            |                                   |
|        |                                         |                                |              |            |                                   |
|        |                                         |                                |              |            |                                   |
|        |                                         |                                |              |            |                                   |
|        |                                         |                                |              |            |                                   |
|        |                                         |                                |              |            |                                   |

[1]: <https://mif.vu.lt/lt3/dokumentai/dokumentai/KOMP/Reglamentuojantys/Reikalavimai_Magistriniams_Darbams.pdf> "Requirements for masters theses"