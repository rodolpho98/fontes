#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

Static cTitulo := "Cadastro de Municipio"
 
User Function TST001()

local cUrl := "http://servicodados.ibge.gov.br/api/v1/localidades/estados/sc/municipios"
local cGetParms := ""
local nTimeOut := 200
local aHeadStr := {"Content-Type: application/json"}
local cHeaderGet := ""
local cRetorno := ""
local oObjJson := nil

local aFields := {}
local oTempTable
local nI

local oBrowse
local aSeek := {}
Private cAlias := "TRB"

cRetorno := HttpGet( cUrl , cGetParms, nTimeOut, aHeadStr, @cHeaderGet )
If !FWJsonDeserialize(cRetorno,@oObjJson)
    MsgStop("Erro ao carregar os dados")
   Return nil
endif

oTempTable := FWTemporaryTable():New( cAlias )

aadd(aFields,{"RB_ID","C",7,0})
aadd(aFields,{"RB_MUNICI","C",70,1})
aadd(aFields,{"RB_MICROR","C",70,0})
aadd(aFields,{"RB_MESORR","C",70,0})

oTemptable:SetFields( aFields )

oTempTable:AddIndex("01", {"RB_ID"} )
oTempTable:AddIndex("02", {"RB_MUNICI"} )

oTempTable:Create()
 
DbSelectArea(cAlias)


//Aqui utilizei a função decodeUTF8 por conta do Ambiente.
for nI = 1 to len(oObjJson) 
    RecLock(cAlias, .T.)
    RB_ID := alltrim(str(oObjJson[nI]:id))
    RB_MUNICI:= Upper(decodeUTF8(oObjJson[nI]:nome))
    RB_MICROR:= Upper(decodeUTF8(oObjJson[nI]:microrregiao:Nome))
    RB_MESORR:= Upper(decodeUTF8(oobjjson[nI]:microrregiao:mesorregiao:Nome)) 
    MsUnLock()
next

Aadd(aSeek,{"ID"        , {{"","C",07,0, "RB_ID"     ,"@!"}}, 1, .T. } )
Aadd(aSeek,{"Municipio" , {{"","C",70,0, "RB_MUNICI" ,"@!"}}, 2, .T. } )

oBrowse := FWMBrowse():New()
oBrowse:SetAlias( cAlias )
oBrowse:SetDescription( cTitulo )
oBrowse:SetSeek(.T.,aSeek)
oBrowse:SetTemporary(.T.)
oBrowse:SetLocate()
oBrowse:SetUseFilter(.T.)
oBrowse:SetDBFFilter(.T.)
oBrowse:SetFilterDefault( "" ) 
oBrowse:DisableDetails()

oColumn := FWBrwColumn():New()
oColumn:SetData({||RB_ID})
oColumn:SetTitle("ID")
oColumn:SetSize(7)
oBrowse:SetColumns({oColumn})
 
oColumn := FWBrwColumn():New()
oColumn:SetData({||RB_MUNICI})
oColumn:SetTitle("Município")
oColumn:SetSize(70)
oBrowse:SetColumns({oColumn})
 
oColumn := FWBrwColumn():New()
oColumn:SetData({||RB_MICROR})
oColumn:SetTitle("Microrregião")
oColumn:SetSize(70)
oBrowse:SetColumns({oColumn})
 
oColumn := FWBrwColumn():New()
oColumn:SetData({||RB_MESORR})
oColumn:SetTitle("Mesorregião")
oColumn:SetSize(70)
oBrowse:SetColumns({oColumn})

oBrowse:Activate()

oTempTable:Delete()

return nil

/****************************************************/
/* MenuDef                                          */
/****************************************************/
Static Function MenuDef()

Local aRot := {}
    
ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.TST001' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 

Return aRot

/****************************************************/
/* ModelDef                                         */
/****************************************************/ 
Static Function ModelDef()

    Local oModel := Nil
    Local oStTRB := FWFormModelStruct():New()
    
    oStTRB:AddTable(cAlias, {'RB_ID', 'RB_MUNICI', 'RB_MICROR', 'RB_MESORR'}, "Temp")
        
    oStTRB:AddField("ID"          ,"ID"          ,"RB_ID"    ,"C",07,0,Nil,Nil,{},.F.,,.T.,.F.,.F.)       
    oStTRB:AddField("Municipio"   ,"Municipio"   ,"RB_MUNICI","C",70,0,Nil,Nil,{},.F.,,.T.,.F.,.F.)     
    oStTRB:AddField("Microrregiao","Microrregiao","RB_MICROR","C",70,0,Nil,Nil,{},.F.,,.T.,.F.,.F.)  
    oStTRB:AddField("Mesorregiao" ,"Mesorregiao" ,"RB_MESORR","C",70,0,Nil,Nil,{},.F.,,.T.,.F.,.F.)   
    oStTRB:AddField("UF"          ,"UF"          ,"RB_UF"    ,"C",02,0,Nil,Nil,{},.F.,FwBuildFeature( STRUCT_FEATURE_INIPAD, "u_buscauf("+cAlias+"->RB_ID,1)" ),.T.,.F.,.T.) 
    oStTRB:AddField("Regiao"      ,"Regiao"      ,"RB_REGIAO","C",70,0,Nil,Nil,{},.F.,FwBuildFeature( STRUCT_FEATURE_INIPAD, "u_buscauf("+cAlias+"->RB_ID,2)" ),.T.,.F.,.T.) 

    oModel := MPFormModel():New("TST001M",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) 

    oModel:AddFields("FORMTRB",/*cOwner*/,oStTRB)

    oModel:SetPrimaryKey({ 'RB_ID' }) 

    oModel:SetDescription("Dados  do "+cTitulo)

    oModel:GetModel("FORMTRB"):SetDescription("Visualizacao do "+cTitulo)

Return oModel
 
/****************************************************/
/* ViewDef                                          */
/****************************************************/
Static Function ViewDef()

    //Local aStruTRB    := (cAlias)->(DbStruct())
    Local oModel := FWLoadModel("TST001")
    Local oStTRB := FWFormViewStruct():New()
    Local oView := Nil

    oStTRB:AddField("RB_ID"    ,"01","ID"          ,"ID"          ,Nil,"C",,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil)   
    oStTRB:AddField("RB_MUNICI","02","Municipio"   ,"Municipio"   ,Nil,"C",,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil) 
    oStTRB:AddField("RB_MICROR","03","Microrregiao","Microrregiao",Nil,"C",,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil) 
    oStTRB:AddField("RB_MESORR","04","Mesorregiao" ,"Mesorregiao" ,Nil,"C",,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil) 
    oStTRB:AddField("RB_UF"    ,"05","UF"          ,"UF"          ,Nil,"C",,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,.T.,Nil,Nil)  
    oStTRB:AddField("RB_REGIAO","06","REGIAO"      ,"REGIAO"      ,Nil,"C",,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,.T.,Nil,Nil)  

    oView := FWFormView():New()
    oView:SetModel(oModel)

    oView:AddField("VIEW_TRB", oStTRB, "FORMTRB")
        
    oView:CreateHorizontalBox("TELA",100)
        
    oView:EnableTitleView('VIEW_TRB', 'Dados do Municipio' )  
        
    oView:SetCloseOnOk({||.T.})

    oView:SetOwnerView("VIEW_TRB","TELA")
Return oView

/****************************************************/
/* BuscaMun  Busca UF e Regiao pelo ID do municipio */
/****************************************************/
user Function buscauf(id_mun,nTipo)

    local cUrl := "https://servicodados.ibge.gov.br/api/v1/localidades/municipios/"+id_mun+"/"
    local cGetParms := ""
    local nTimeOut := 200
    local aHeadStr := {"Content-Type: application/json"}
    local cHeaderGet := ""
    local cRetorno := ""
    local oObjJson := nil
    Local cRet     := ""

    cRetorno := HttpGet( cUrl , cGetParms, nTimeOut, aHeadStr, @cHeaderGet )
    If !FWJsonDeserialize(cRetorno,@oObjJson)
        MsgStop("Erro ao carregar os dados")
    Return nil
    endif

    if nTipo = 1
        cRet:= oObjJson:microrregiao:mesorregiao:uf:sigla
    elseif nTipo = 2
        cRet:= Upper(oObjJson:microrregiao:mesorregiao:uf:regiao:nome)
    endif

return(cRet)
