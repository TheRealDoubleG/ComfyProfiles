ComfyProfiles=ComfyProfiles or {}
local A=ComfyProfiles
A.suiteAddons={"ComfyHub","ComfyOnPoint","ComfyBar","ComfyCC","ComfyMacro","ComfyEnemyBar","ComfyPanel","ComfyBag","ComfyMog","ComfyXP","ComfyKey","ComfyGatherer","ComfyKills"}
local function Provider(name) local a=rawget(_G,name); if type(a)=="table" and type(a.GetActiveStorageProfileKey)=="function" and type(a.SetActiveStorageProfile)=="function" then return a end end
function A:CaptureSuiteState() local out={} for _,name in ipairs(self.suiteAddons) do local p=Provider(name); if p then local k=p:GetActiveStorageProfileKey(); out[name]={key=k,label=type(p.GetStorageProfileLabel)=="function" and p:GetStorageProfileLabel(k) or tostring(k)} end end return out end
function A:GetPresetNames() local list={} for n in pairs(self.db.suite.presets or {}) do list[#list+1]={value=n,text=n} end table.sort(list,function(a,b) return a.text:lower()<b.text:lower() end); return list end
function A:SaveSuitePreset(name) name=tostring(name or ""):match("^%s*(.-)%s*$"); if name=="" then return false end; self.db.suite.presets[name]=self:CaptureSuiteState(); self.db.suite.selected=name; self:RefreshOptions(); return true end
function A:PreviewSuitePreset(name) local pset=self.db.suite.presets[name]; if type(pset)~="table" then return self:T("NO_PROFILE") end; local lines={}; for _,addonName in ipairs(self.suiteAddons) do local target=pset[addonName]; if target then local p=Provider(addonName); if not p then lines[#lines+1]=addonName..": "..self:T("NOT_LOADED") else local cur=p:GetActiveStorageProfileKey(); if cur~=target.key then local label=type(p.GetStorageProfileLabel)=="function" and p:GetStorageProfileLabel(cur) or tostring(cur); lines[#lines+1]=addonName..": "..tostring(label).." -> "..tostring(target.label or target.key) end end end end; return #lines>0 and table.concat(lines,"\n") or self:T("NO_CHANGES") end
function A:ApplySuitePreset(name) local pset=self.db.suite.presets[name]; if type(pset)~="table" then return false end; self.db.suite.recovery=self:CaptureSuiteState(); local failed={}; for addonName,target in pairs(pset) do local p=Provider(addonName); if p and target.key then local ok=p:SetActiveStorageProfile(target.key); if not ok then failed[#failed+1]=addonName end elseif target then failed[#failed+1]=addonName end end; if #failed>0 then self:Print(self:T("APPLY_PARTIAL")..": "..table.concat(failed,", ")) end; self:RefreshOptions(); return true end
function A:RestoreRecovery() local r=self.db.suite.recovery; if type(r)~="table" then return false end; for addonName,target in pairs(r) do local p=Provider(addonName); if p and target.key then p:SetActiveStorageProfile(target.key) end end; self:RefreshOptions(); return true end
local function Esc(v) return tostring(v or ""):gsub("%%","%%25"):gsub("|","%%7C"):gsub("\n","%%0A") end
local function Unesc(v) return tostring(v or ""):gsub("%%0A","\n"):gsub("%%7C","|"):gsub("%%25","%%") end
function A:ExportPreset(name) local pset=self.db.suite.presets[name]; if type(pset)~="table" then return "" end; local lines={"COMFYPROFILES1","name|"..Esc(name)}; for _,addonName in ipairs(self.suiteAddons) do local x=pset[addonName]; if x then lines[#lines+1]=Esc(addonName).."|"..Esc(x.key).."|"..Esc(x.label) end end; return table.concat(lines,"\n") end
function A:ImportPreset(text) local lines={} for line in tostring(text or ""):gmatch("[^\r\n]+") do lines[#lines+1]=line end; if lines[1]~="COMFYPROFILES1" then return false end; local name=lines[2] and lines[2]:match("^name|(.+)$"); name=Unesc(name); if not name or name=="" then return false end; local pset={}; for i=3,#lines do local a,k,l=lines[i]:match("^(.-)|(.-)|(.*)$"); if a and k then pset[Unesc(a)]={key=Unesc(k),label=Unesc(l)} end end; self.db.suite.presets[name]=pset; self.db.suite.selected=name; self:RefreshOptions(); return true end
function A:RefreshFeatureOptions() if self.profileDropdown and self.profileDropdown._refresh then self.profileDropdown._refresh() end; if self.previewBox then self.previewBox:SetText(self:PreviewSuitePreset(self.db.suite.selected)) end end
function A:BuildGeneralOptions(page,ui)
 local l=page:CreateFontString(nil,"ARTWORK","GameFontNormal"); l:SetPoint("TOPLEFT",20,-90); l:SetText(self:T("SUITE_PROFILE"))
 self.profileDropdown=ui.CreateDropdown(page,5,-105,220,function() return A:GetPresetNames() end,function() return A.db.suite.selected end,function(v) A.db.suite.selected=v end)
 self.profileName=ui.CreateEdit(page,270,-105,190,28,false)
 ui.CreateButton(page,self:T("SAVE_CURRENT"),470,-102,120,function() local n=A.profileName:GetText(); if A:SaveSuitePreset(n) then A.profileName:SetText("") end end)
 ui.CreateButton(page,self:T("APPLY"),600,-102,100,function() A:ApplySuitePreset(A.db.suite.selected) end)
 ui.CreateButton(page,self:T("DELETE"),20,-160,100,function() local n=A.db.suite.selected; if n then A.db.suite.presets[n]=nil; A.db.suite.selected=nil; A:RefreshOptions() end end)
 ui.CreateButton(page,self:T("RECOVERY"),130,-160,130,function() A:RestoreRecovery() end)
 ui.CreateButton(page,self:T("EXPORT"),270,-160,100,function() if A.ioBox then A.ioBox:SetText(A:ExportPreset(A.db.suite.selected)); A.ioBox:HighlightText() end end)
 ui.CreateButton(page,self:T("IMPORT"),380,-160,100,function() if A.ioBox then A:ImportPreset(A.ioBox:GetText()) end end)
 local pt=page:CreateFontString(nil,"ARTWORK","GameFontNormal"); pt:SetPoint("TOPLEFT",20,-210); pt:SetText(self:T("PREVIEW"))
 self.previewBox=ui.CreateEdit(page,20,-235,680,130,true); self.previewBox:SetEnabled(false)
 local it=page:CreateFontString(nil,"ARTWORK","GameFontNormal"); it:SetPoint("TOPLEFT",20,-385); it:SetText(self:T("IMPORT_EXPORT"))
 self.ioBox=ui.CreateEdit(page,20,-410,680,115,true)
 local n=page:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall"); n:SetPoint("TOPLEFT",20,-540); n:SetWidth(680); n:SetJustifyH("LEFT"); n:SetText(self:T("FOREVER_NOTE"))
end
function A:InitializeFeature() end
function A:RefreshFeature() end
