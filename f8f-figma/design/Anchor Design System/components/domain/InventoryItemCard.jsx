import React from 'react';
const CAT={hardware:{bg:'var(--blue-100)',fg:'#1e40af'},software:{bg:'var(--purple-100)',fg:'var(--purple-700)'},supplies:{bg:'var(--yellow-100)',fg:'var(--yellow-700)'},equipment:{bg:'var(--slate-100)',fg:'var(--slate-700)'},other:{bg:'var(--slate-100)',fg:'var(--slate-700)'}};
export function InventoryItemCard({name,sku,category='other',stock=0,minStock=10,price=0}){
  const low=stock<=minStock; const c=CAT[category]||CAT.other;
  return React.createElement('div',{style:{background:'rgba(255,255,255,0.8)',borderRadius:'var(--radius-xl)',boxShadow:'var(--shadow-md)',padding:20,display:'flex',flexDirection:'column',gap:12}},
    React.createElement('div',{style:{display:'flex',justifyContent:'space-between',alignItems:'flex-start',gap:8}},
      React.createElement('div',{style:{fontWeight:700,fontSize:16,color:'var(--slate-800)'}},name),
      React.createElement('span',{style:{fontSize:11,fontWeight:700,padding:'2px 8px',borderRadius:6,whiteSpace:'nowrap',background:low?'var(--red-600)':'var(--muted)',color:low?'#fff':'var(--foreground)'}},stock,' in stock')),
    React.createElement('div',{style:{fontSize:12,color:'var(--muted-foreground)',fontFamily:'var(--font-mono)'}},sku),
    React.createElement('span',{style:{fontSize:11,fontWeight:600,padding:'2px 8px',borderRadius:6,background:c.bg,color:c.fg,alignSelf:'flex-start'}},category),
    React.createElement('div',{style:{display:'flex',justifyContent:'space-between',alignItems:'center',borderTop:'1px solid var(--border)',paddingTop:12}},
      React.createElement('span',{style:{fontWeight:700,fontSize:18}},'$'+price.toFixed(2)),
      React.createElement('button',{style:{fontSize:13,fontWeight:600,padding:'6px 14px',borderRadius:'var(--radius-md)',background:'var(--primary)',color:'#fff',border:'none',cursor:'pointer'}},'Edit')));
}
