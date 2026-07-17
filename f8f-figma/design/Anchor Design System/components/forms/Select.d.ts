/** Dropdown select — used for status/priority pickers on item detail screens. Simplified native-select recreation (source uses Radix Select; visuals match, interaction simplified). @startingPoint section="Forms" subtitle="Dropdown select for status/priority" viewport="700x110" */
export interface SelectOption{ value:string; label:string; }
export interface SelectProps{ value?:string; onValueChange?:(v:string)=>void; options:SelectOption[]; placeholder?:string; }
export function Select(props: SelectProps): JSX.Element;
