function Sidebar({active,onNav,company,onLogout}){
  const Icon=window.AnchorIcon;
  const items=[{label:'Dashboard',path:'dashboard',icon:'layout-dashboard'},{label:'Pipeline',path:'kanban',icon:'kanban'},{label:'Inventory',path:'inventory',icon:'package'}];
  return (
    <aside style={{width:240,background:'var(--slate-900)',display:'flex',flexDirection:'column',flexShrink:0}}>
      <div style={{display:'flex',alignItems:'center',gap:8,padding:'16px 20px',borderBottom:'1px solid var(--sidebar-border)'}}>
        <div style={{width:28,height:28,borderRadius:8,background:'var(--blue-500)',display:'flex',alignItems:'center',justifyContent:'center'}}><Icon name="anchor" size={16} color="#fff"/></div>
        <span style={{color:'#fff',fontWeight:700,fontSize:18}}>Anchor</span>
      </div>
      {company && <div style={{padding:'12px 16px',borderBottom:'1px solid var(--sidebar-border)'}}>
        <p style={{color:'var(--sidebar-fg-muted)',fontSize:11,textTransform:'uppercase',letterSpacing:'0.05em',margin:0}}>Workspace</p>
        <p style={{color:'#fff',fontWeight:600,fontSize:14,margin:'2px 0 0'}}>{company}</p>
      </div>}
      <nav style={{flex:1,padding:'16px 12px',display:'flex',flexDirection:'column',gap:4}}>
        {items.map(it=>{
          const isActive=active===it.path;
          return (<button key={it.path} onClick={()=>onNav(it.path)} style={{display:'flex',alignItems:'center',gap:12,padding:'10px 12px',borderRadius:8,border:'none',fontSize:14,fontWeight:500,cursor:'pointer',fontFamily:'var(--font-sans)',textAlign:'left',background:isActive?'var(--blue-600)':'transparent',color:isActive?'#fff':'var(--sidebar-fg-muted)'}}>
            <Icon name={it.icon} size={16} color={isActive?'#fff':'var(--sidebar-fg-muted)'}/>{it.label}
          </button>);
        })}
      </nav>
      <div style={{padding:16,borderTop:'1px solid var(--sidebar-border)'}}>
        <button onClick={onLogout} style={{display:'flex',alignItems:'center',gap:8,background:'none',border:'none',color:'var(--sidebar-fg-muted)',fontSize:13,cursor:'pointer',fontFamily:'var(--font-sans)',width:'100%'}}>
          <Icon name="log-out" size={14} color="var(--sidebar-fg-muted)"/>Sign out
        </button>
      </div>
    </aside>
  );
}
window.Sidebar = Sidebar;
