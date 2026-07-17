/** Multi-line text field for issue descriptions, notes, quick-intake free text. @startingPoint section="Forms" subtitle="Multi-line text field" viewport="700x140" */
export interface TextareaProps{ placeholder?:string; value?:string; rows?:number; onChange?:(e:any)=>void; style?:React.CSSProperties; }
export function Textarea(props: TextareaProps): JSX.Element;
