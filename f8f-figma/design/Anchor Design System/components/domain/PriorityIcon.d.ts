/** Small colored glyph indicating item priority (low/medium/high/urgent) — mirrors Lucide ArrowDown/Up/ChevronsUp/ChevronsDown from the source. @startingPoint section="Domain" subtitle="Priority glyph, 4 levels" viewport="700x90" */
export interface PriorityIconProps{ priority:'low'|'medium'|'high'|'urgent'; }
export function PriorityIcon(props: PriorityIconProps): JSX.Element;
