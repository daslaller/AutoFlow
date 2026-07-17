import React from 'react';
export function Accordion({items=[]}){
  const [openIdx,setOpenIdx]=React.useState(null);
  return React.createElement('div',{style:{display:'flex',flexDirection:'column'}},
    items.map((it,i)=>React.createElement('div',{key:i,style:{borderBottom:'1px solid var(--border)'}},
      React.createElement('button',{onClick:()=>setOpenIdx(openIdx===i?null:i),style:{width:'100%',textAlign:'left',padding:'12px 0',background:'none',border:'none',fontWeight:600,fontSize:14,cursor:'pointer',color:'var(--foreground)',fontFamily:'var(--font-sans)'}},it.title),
      openIdx===i&&React.createElement('div',{style:{paddingBottom:12,fontSize:13,color:'var(--muted-foreground)'}},it.content))));
}
