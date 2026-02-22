# GPT Context Guides

Guidelines for how the GPT should interpret and retrieve knowledge from this repository.

## Core Principles

- Use the project README truth hierarchy before referencing other docs.
- For production AWS operational questions, route to `work-system-aws-config/README.md` first, then the relevant service subfolder.
- Prefer service report markdown for summaries and raw JSON/TXT exports for exact values.
- If information is missing, explicitly state the gap and request the minimal missing detail.
- Prefer Markdown sources over images and binaries when both contain equivalent information.
