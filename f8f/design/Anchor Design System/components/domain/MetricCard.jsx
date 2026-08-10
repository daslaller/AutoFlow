import React from 'react';
const GRADIENTS={blue:'linear-gradient(to bottom right,var(--blue-500),var(--blue-600))',green:'linear-gradient(to bottom right,var(--green-500),var(--green-600))',purple:'linear-gradient(to bottom right,var(--purple-500),var(--purple-600))',red:'linear-gradient(to bottom right,var(--red-500),var(--red-600))'};
export function MetricCard({title,value,sub,color='blue',iconGlyph='●'}){
  return React.createElement('div',{style:{background:'var(--card)',borderRadius:'var(--radius-xl)',boxShadow:'var(--shadow-md)',padding:20}},
    React.createElement('div',{style:{display:'flex',justifyContent:'space-between',alignItems:'flex-start'}},
      React.createElement('div',null,
        React.createElement('div',{style:{fontSize:13,color:'var(--muted-foreground)',fontWeight:500}},title),
        React.createElement('div',{style:{fontSize:28,fontWeight:700,color:'var(--foreground)',marginTop:4}},value),
        sub&&React.createElement('div',{style:{fontSize:11,color:'var(--slate-400)',marginTop:4}},sub)),
      React.createElement('div',{style:{width:40,height:40,borderRadius:'var(--radius-lg)',background:GRADIENTS[color]||GRADIENTS.blue,display:'flex',alignItems:'center',justifyContent:'center',color:'#fff',fontSize:16}},iconGlyph)));
}
