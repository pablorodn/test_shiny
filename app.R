library(shiny)
library(bs4Dash)
library(glue)
library(httr)
library(jsonlite)
library(dplyr)
library(DT)
library(lubridate)
library(leaflet)
library(stringr)

source(file = glue("{getwd()}/get_query.R"), local=TRUE)
  '%ni%'=Negate('%in%')

  #load the sidebar
  dashboard_ui <- function() {

        tags$style(type='text/css',".main-sidebar{width: 200px;},.selectize-input {height: 10px; width: 200px; font-size: 12px; padding-top: 5px;font-size: 14px; line-height: 14px;} .selectize-dropdown { font-size: 14px; line-height: 14px; } .form-group, .selectize-control {margin-bottom:10px;max-height: 100px !important;} .box-body { padding-bottom: 20px; }")
        selectizeInput("selection", div(style = "font-size:14px", "Please fill the name of the specie (Scientific or Vernacular):"),
                       choices=NULL,multiple=T,selected=NULL,options = list(closeAfterSelect = TRUE))

  }
  #load the list of scientific or vernacular names
  nameChoices<-function(){
    
  nameChoices=get_query("select DISTINCT co.vernacularName,co.scientificName from ab.chunked_occurence co
                        where co.vernacularName is not null and co.scientificName is not null")
  nameChoices=c(nameChoices$vernacularName,nameChoices$scientificName)
  nameChoices=nameChoices[which(!grepl("['._]+",nameChoices))]
  nameChoices=nameChoices[order(nameChoices)]
  return(nameChoices)}
  #Function to load information about the specie
  data_specie<-function(parameter){
    parameter=paste(paste0("'",parameter,"'"), collapse = ",")
    data=glue("select po.scientificName,po.vernacularName,po.country,po.individualCount,po.longitudeDecimal,po.latitudeDecimal,po.locality,po.eventDate,pm.accessURI from ab.chunked_occurence po left join ab.chunked_multimedia pm on po.id=pm.CoreId
    where po.scientificName in ({parameter}) or po.vernacularName in ({parameter})
    and po.vernacularName is not null and po.scientificName is not null
    order by po.eventDate")
    data=get_query(data)
    return(data)}
  #Function for render image_box
  image_box=function(data_specie,image_value){
    tags$head(tags$style( type="text/css", "#image img {max-width: 100%; width: 100%; height: auto}" ))
    df=data_specie[which(!is.na(data_specie$scientificName)),]
    df=inner_join(df %>%
                   group_by(scientificName)%>%
                   summarize("frequency"=sum(individualCount)),
                 df %>%
                   group_by(scientificName)%>%
                   mutate(date = ymd(eventDate)) %>% 
                   summarise(min = min(date),
                             max = max(date))%>% 
                   mutate(diff=as.numeric(difftime(max,min,units = "days")))
    )
    
    df<-left_join(data_specie %>%
      group_by(scientificName) %>%
      summarize(images = n_distinct(accessURI)),df)
    df$frequency=paste0(round(df$frequency/df$diff,2)," times/day")
    df=df[order(-df$images),]
    
    df$open = shinyInput(
      FUN = actionButton,
      n = nrow(df),
      id = 'button_',
      label ="show",
      style="padding:5px; font-size:80%;color: #fff; background-color: #87ae7c; border-color: #87ae7c",
      onclick = 'Shiny.setInputValue(\"select_button_dt\", this.id,{priority: \"event\"})'
    )
    
    df[which(df$images==0),"open"]=""
    df=df[,c(1,3,7)]
    df_input<<-df
    tbl = renderDataTable({
      DT::datatable(df,
                          class = 'compact',
                          rownames=FALSE,
                          extensions = list("Scroller"),
                          options = list(dom='t',info=FALSE,autoWidth = FALSE,
                                         lengthChange = TRUE,sScrollY = '27vh', scrollCollapse = TRUE,pageLength = nrow(df),paging = FALSE,
                                         scrollX = T,initComplete = JS(
                                           "function(settings, json) {",
                                           "$(this.api().table().header()).css({'font-size': '80%'});",
                                           "}")),
                          selection=list(mode="single", target="row"),
                          filter = 'none',escape = FALSE,editable = FALSE)%>%
      formatStyle(columns = c(1:ncol(df)), fontSize = '80%')%>%
      formatStyle(1,color = 'black',fontSize = '80%')%>%
      formatStyle(ncol(df),color = 'black',fontSize = '80%',fontWeight = 'bold')
    })
    
    

    if(colnames(data_specie)[ncol(data_specie)]=="accessURI"){
    data_specie=filter(data_specie,accessURI==image_value)
    dov=paste0("Date of Event: ",data_specie$eventDate)
    data_specie=paste0(data_specie$locality)
    }else{
      data_specie="No Images!" 
      dov=""
    }
    bs4Card(
      title = "Image Render",
      width = 12,
      height='100%',
      status = "olive",
      closable = FALSE,
      maximizable = FALSE,
      collapsible = FALSE,
      solidHeader = TRUE,
      tags$h4(if_else(data_specie!="No Images!",paste0("Location: ",data_specie),data_specie), class = "text-center", style = "padding-top: 0;color: black;font-size: 14px; font-weight:400; font-weight:bold;"),
      tags$h5(dov,class = "text-center", style = "padding-top: 0;color: black;font-size: 12px; font-weight:500; font-weight:bold;"),
      img(src=image_value,align = "center", style = paste0("width: 100%; height: ", "10em", ";")),
      tbl
      ) 
      }
  #Function for render leaflet map box
  map_box=function(data_specie,image_value){
    if(colnames(data_specie)[ncol(data_specie)]=="accessURI"){
        mirror=filter(data_specie,is.na(accessURI)==F)
        mirror$icon_parameter="fa-solid fa-camera"
        mirror$status="lightgreen"
        data_specie=data_specie[duplicated(paste(data_specie$latitudeDecimal,data_specie$longitudeDecimal,sep="*"))==F,]
        data_specie$icon_parameter="fa-regular fa-eye"
        data_specie$status="blue"
        data_specie=data_specie[which(data_specie$accessURI %ni% mirror$accessURI),]
        data_specie=rbind(mirror,data_specie)
    }else{
        data_specie=data_specie[duplicated(paste(data_specie$latitudeDecimal,data_specie$longitudeDecimal,sep="*"))==F,]
        data_specie$icon_parameter="fa-regular fa-eye"
        data_specie$status="blue"
    }

    mymap <- renderLeaflet({
      df=data_specie
      
      df1=filter(df,status=="blue")
      df2=filter(df,status!="blue")

        map=leaflet() %>% 
        addProviderTiles(providers$CartoDB)
        if(nrow(df1)>0){
          icons_df1 <- awesomeIcons(
            icon =df1$icon_parameter, 
            iconColor = 'black',
            markerColor = if_else(df1$status!="blue","lightgreen","blue"),
            library = 'fa')
          
          map=addAwesomeMarkers(map,df1$longitudeDecimal,df1$latitudeDecimal,icon=icons_df1, popup =df1$locality,group = "View",
                          options = popupOptions(closeButton = TRUE,textsize = "10px"),label =(paste0("Name:",df1$scientificName,"/",df1$locality)),labelOptions=labelOptions(textsize = "10px")) 
        }
        if(nrow(df2)>0){
          
          icons_df2 <- awesomeIcons(
          icon =df2$icon_parameter, 
          iconColor = 'black',
          markerColor = if_else(df2$status!="blue","lightgreen","blue"),
          library = 'fa')
          icon_selected <- awesomeIcons(
            icon ="fa-regular fa-compass", 
            iconColor = 'black',
            markerColor ="lightblue",
            library = 'fa')
          
          df_selected=df2[df2$accessURI==image_value,]
          df2=df2[df2$accessURI!=image_value, ]
      map=addAwesomeMarkers(map,df2$longitudeDecimal,df2$latitudeDecimal,icon=icons_df2,popup =paste0('<img src="',df2$accessURI,'" align="center" style="width: 120%;"/>'),group = "Photo",
                                    options = popupOptions(closeButton = T,textsize = "10px",keepInView = T),label =(paste0("Name:",df2$scientificName,"/",df2$locality)),labelOptions=labelOptions(textsize = "10px")) 
      
      map=addAwesomeMarkers(map,df_selected$longitudeDecimal,df_selected$latitudeDecimal,icon=icon_selected,popup =paste0('<img src="',df_selected$accessURI,'" align="center" style="width: 120%;"/>'),group = "Photo",
                            options = popupOptions(closeButton = T,textsize = "10px",keepInView = T),label =(paste0("Name:",df_selected$scientificName,"/",df_selected$locality)),labelOptions=labelOptions(textsize = "10px")) 
      
      map=setView(map,df_selected$longitudeDecimal,df_selected$latitudeDecimal, zoom = 12)
      
      
      }
      map=addLayersControl(map,
        overlayGroups = c("View", "Photo"),
        options = layersControlOptions(collapsed = FALSE)
      )

      map
    
    })
    bs4Card(
      title = "Location Map",
      width = 12,
      height='100%',
      status = "olive",
      color="olive",
      closable = FALSE,
      maximizable = FALSE,
      collapsible = FALSE,
      solidHeader = TRUE,
      mymap
    )
    
  }
  #UI to render timeline
  timeline_box=function(data_specie,image_value){
    scientific_name=filter(data_specie,accessURI==image_value)
    scientific_name=scientific_name$scientificName
    data_specie=data_specie[data_specie$scientificName==scientific_name,]
    data_specie$dummie=unlist(lapply(strsplit(data_specie$locality, '-', fixed = TRUE), '[', 2))
    data_specie[is.na(data_specie$dummie),"dummie"]=data_specie$locality[is.na(data_specie$dummie)]
    data_specie$year=lubridate::year(data_specie$eventDate)
    data_specie[is.na(data_specie$accessURI)==T,"accessURI"]="https://i.ibb.co/xmLwdHT/Imagen-1.jpg"
    
    
    df= data_specie %>% 
      group_by(year) %>% 
      mutate(string = paste0(paste(dummie,eventDate,sep="-"), collapse = ",")) %>% 
      mutate(events = sum(individualCount))%>%
      distinct(year, string, .keep_all = TRUE) %>% select(year,events,string)
    min_year=min(df$year)
    max_year=max(df$year)
    result=lapply(1:nrow(data_specie), function(i){
        temp=data_specie[i,]
        glue('bs4TimelineItem(title="",icon=icon("paint-brush"),color = "teal",time="",footer="{temp$eventDate}","Event: {temp$locality}",border = F);')
      })
    result=do.call(rbind,result)
    
    bs4Card(
      title = "Timeline Render",
      width = 12,
      style='width:400px;overflow-x: scroll;height:400px;overflow-y: scroll;',
      height='100%',
      status = "olive",
      color="olive",
      closable = FALSE,
      maximizable = FALSE,
      collapsible = FALSE,
      solidHeader = TRUE,
      bs4Timeline(width = "100%",height='100%',reversed = TRUE,
                    timelineEnd(color = "danger"),
                    bs4TimelineLabel(paste0("First occurence: ",min_year), status = "info"),
                    lapply(1:length(result), function(i){
                    eval(parse(text = result[i]))
                    }),
                    
                    bs4TimelineLabel(paste0("Last occurence: ",max_year), status = "info"),
                    timelineStart(color = "secondary")
        )
      )
    
  }
  #UI to show empty info
  empty_ui<-function(){
    h4("There is no info about this specie for this feature")
  }
  #Render buttons on DT
  shinyInput <- function(FUN, n, id, ...) {
    
    vapply(seq_len(n), function(i){
      as.character(FUN(paste0(id, i), ...))
    }, character(1))
    
  }
  #UI Basic
  ui = {dashboardPage(
    title = "Global Biodiversity Information Facility",
    fullscreen = TRUE,
    header = dashboardHeader(
      title = dashboardBrand(
        title = "GBIF | Database",
        color = "white",
        href = "https://www.gbif.org/occurrence/search?dataset_key=8a863029-f435-446a-821e-275f4f641165",
        image = "https://images.ctfassets.net/uo17ejk9rkwj/7EHyiE4vj5EIlhlFX11zzL/2d895c132a9dc2834665f04d8b38b760/icon-home-21.svg",
      ),
      skin = "light",
      status = "white",
      border = F,
      fixed = FALSE,
      dashboard_ui()
    ),
    sidebar = dashboardSidebar(disable = T),
    body = uiOutput("body")

  )}
  
  server = function(input, output,session) {

    

      updateSelectizeInput(
        session, "selection", choices=nameChoices(), server = T, 
        options = list(maxOptions = 20,closeAfterSelect = TRUE),selected=c("Abraxas grossulariata","Acer negundo") 
      )
  
    observeEvent(input$select_button_dt,{
      
      
      selectedRow <- as.numeric(strsplit(input$select_button_dt,"_")[[1]][2])
      selectedRow=df_input[selectedRow,"scientificName"]
      selectedRow=as.character(selectedRow)
      selectedRow=dplyr::filter(data_selected,scientificName==selectedRow)
      selectedRow=selectedRow[!is.na(selectedRow$accessURI),"accessURI"]
      selectedRow=sample(selectedRow,1)
      
      output$ui_img<-renderUI(image_box(data_selected,selectedRow))
      output$ui_mp<-renderUI(map_box(data_selected,selectedRow))
      output$ui_tl<-renderUI(timeline_box(data_selected,selectedRow))
    })
    
    


  observeEvent(input$selection,{

    if(!all(is.na(input$selection))){
    
      
    data_selected<<-data_specie(input$selection)
    
    image_value<-reactive({
        
      if(!all(is.na(data_selected$accessURI))){
        parameter=data_selected$accessURI[is.na(data_selected$accessURI)==F]
        image_value=parameter[sample(1:length(parameter),1)]
      }else{
        image_value="https://i.ibb.co/xmLwdHT/Imagen-1.jpg"
      }
      return(image_value)
    })
    
    output$ui_img<-renderUI(image_box(data_selected,image_value()))
    output$ui_mp<-renderUI(map_box(data_selected,image_value()))
    output$ui_tl<-renderUI(timeline_box(data_selected,image_value()))
      output$body<-renderUI(
        dashboardBody(
          tags$style(type='text/css',".navbar-gray-dark { background-color: white; } .navbar-white { background-color: white; }"),
          tags$head(tags$style(HTML('.row div {padding: 0.5% 0.5% 0.5% !important;}'))),
          fluidRow(
            column(3,uiOutput("ui_img")),
            column(5,uiOutput("ui_mp")),
            column(4,uiOutput("ui_tl"))
          )
        )
      )

    }
  
  })  
    
  }

shinyApp(ui = ui, server = server)

