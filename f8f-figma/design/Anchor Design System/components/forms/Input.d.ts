/** Single-line text field. @startingPoint section="Forms" subtitle="Text inputs, search, and quick-add fields" viewport="700x260" */
export interface InputProps{ type?:string; placeholder?:string; value?:string; onChange?:(e:any)=>void; disabled?:boolean; style?:React.CSSProperties; }
export function Input(props: InputProps): JSX.Element;
