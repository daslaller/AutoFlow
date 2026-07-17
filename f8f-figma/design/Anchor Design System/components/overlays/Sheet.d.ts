/** Right-side slide-over panel, used for the Add/Edit Inventory Item form. @startingPoint section="Overlays" subtitle="Right-side slide-over panel" viewport="700x260" */
export interface SheetProps{ open:boolean; onOpenChange:(open:boolean)=>void; children?: React.ReactNode; }
export function Sheet(props: SheetProps): JSX.Element;
export function SheetHeader(props:{children?:React.ReactNode}): JSX.Element;
export function SheetTitle(props:{children?:React.ReactNode}): JSX.Element;
export function SheetDescription(props:{children?:React.ReactNode}): JSX.Element;
