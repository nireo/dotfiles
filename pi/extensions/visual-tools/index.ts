/**
 * visual-tools
 *
 * Registers the Mermaid and SVG authoring tools as a normal Pi extension.
 * @tintinweb/pi-subagents loads normal extensions in child sessions, so the
 * maker agents can expose these tools through `ext:visual-tools/...` selectors
 * in their frontmatter.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent"
import mermaidToolsExtension from "./tools/mermaid_tools.ts"
import svgToolsExtension from "./tools/svg_tools.ts"

export default function visualToolsExtension(pi: ExtensionAPI) {
  mermaidToolsExtension(pi)
  svgToolsExtension(pi)
}
