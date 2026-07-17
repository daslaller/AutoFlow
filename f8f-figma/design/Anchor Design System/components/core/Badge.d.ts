/**
 * Small status/tag pill. In product screens it's almost always recolored inline (e.g. bg-blue-100 text-blue-700) to encode work status, priority, or category — see the Domain group's StatusBadge/PriorityBadge for the semantic-color versions.
 * @startingPoint section="Core" subtitle="Tag/status pill, 4 variants" viewport="700x90"
 */
export interface BadgeProps{ variant?:'default'|'secondary'|'destructive'|'outline'; children?: React.ReactNode; }
export function Badge(props: BadgeProps): JSX.Element;
