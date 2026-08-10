/** Inventory grid tile — name, SKU, category, live stock badge (turns red at/under min level), price, edit action. @startingPoint section="Domain" subtitle="Inventory grid tile with low-stock badge" viewport="700x240" */
export interface InventoryItemCardProps{ name:string; sku:string; category?:'hardware'|'software'|'supplies'|'equipment'|'other'; stock?:number; minStock?:number; price?:number; }
export function InventoryItemCard(props: InventoryItemCardProps): JSX.Element;
