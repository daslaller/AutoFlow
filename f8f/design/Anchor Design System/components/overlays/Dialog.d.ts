/** Centered modal dialog with backdrop — used for the serial-number manager and other focused tasks. @startingPoint section="Overlays" subtitle="Centered modal with backdrop" viewport="700x260" */
export interface DialogProps{ open:boolean; onOpenChange:(open:boolean)=>void; children?: React.ReactNode; }
export function Dialog(props: DialogProps): JSX.Element;
export function DialogHeader(props: {children?:React.ReactNode}): JSX.Element;
export function DialogTitle(props: {children?:React.ReactNode}): JSX.Element;
export function DialogDescription(props: {children?:React.ReactNode}): JSX.Element;
