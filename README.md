<h1><b>Shiny for my application to Appsilon</b></h1>
<h5> The scope of this repo is to explain the develop proccess of a Shiny app to visualize information about species,  the data comes from the Global Biodiversity Information Facility, at first there is a explanation about the tool, how it works and his features, after that will be a summary of the business/technical requirements and the infrastructure used for this case</h5>




<a href="http://34.201.151.75:3838/test_shiny/"><h4>open the aplication using this link!</h4></a>




<h2>General View </h2>


![image](https://user-images.githubusercontent.com/113043356/189246425-fefdad0e-7002-4305-97bb-17e2bae1cfa2.png)

<br>

<p><em>-Artifact Overview</em></p>

<table border="1">
<thead>
<tr><th>id</th><th>description</th><th>shiny tool used</th></tr>
</thead>
<tbody>
<tr><td>1</td><td>A dropdown menu, who allows multiple selections, contains a list of the scientific/vernacular name of the species, is filled by default with two random names, but the user can drop and do his selection also delete a previous selected item</td><td>The artifact is a 'SelectizeInput' (Deployed in UI), this item its supported by an 'updateSelectizeInput' who deploys max 20 options, the events of the app are related to this input, when react get all the information from the input selected</td></tr>
<tr><td>2</td><td>Image of a random specie, when the user select an input (multiple or unique) display a random photo of the choices (if exists)</td><td>bs4Card' who renderizes a image provided by the random input of the user, the image its deployed parsing html code with the url associated, its 'width', 'height' autoajustable according the img resolution</td></tr>
<tr><td>3</td><td>Table with the scientific name of the specie, the frequency of appearance, (Times by Day), how many times the event occur, is the total of the events split on the difference (in days) between the max and min date of the total events for specie, also have a button who display random images of the specie selected </td><td>DtTable', with format conditional for every column, also have buttons renderized with raw html code, who gives input for reactive events, the image and the table are in the same card</td></tr>
<tr><td>4</td><td>Map with the location of the occurances by the selected species, it the event contains a photo, the user renders a thumbnail, also have all the icons of the observations, the user can choice between observations with or without photos, also if the user select a marker displays the name of the place and the scientific name of the observation</td><td>Leafletmap' with conditional events for every case, renderize multiple markers and icons using 'fontawesome' library, its embedeed in a card, use raw code to display the images in the popups using html with the url, when the users push any button of the previous table, choice a random photo and center on the screen</td></tr>
<tr><td>5</td><td>Timeline who displays the occurrences for the selected species, at first load all the events for all the inputs selected, when the user selects a button at the table, displays only the events for the selected specie, mention the date and the location</td><td>Is a bs4card, also have a bs4Timeline with start/end events, this artifact also have and 'bs4TimelineItem' who is renderized by a lapply loop, (raw code parsed)</td></tr>
</tbody>
</table>

<br>


<h2>Technical requirements </h2>

<p><em>-Default view when no species is selected yet should make sense to the user. It shouldn’t be just an empty map and plot. Please decide what you will display</em></p>


![image](https://user-images.githubusercontent.com/113043356/189256855-c4f63b49-9cf5-426e-925d-2463c8566e3d.png)


<p><em>-Add readme that will help potential future developers of this app</em></p>

<h5> You're reading the readme file</h5>

<p><em>-Deploy the app to shinyapps.io</em></p>

<h5> The app is deployed into a aws ec2 spot machine file</h5>

<p><em>-Decompose independent functionalities into shinyModules</em></p>
<h5> There is a lot of shinymodules who support the UI and the server components (Headlines of app.R script)</h5> 

![image](https://user-images.githubusercontent.com/113043356/189251990-3b0fd230-7514-4f12-a930-f456b166c17e.png)


<p><em>-Add unit tests for the most important functions and cover edge cases.</em></p>
<h5> Unit test have been performed, registered and saved, using package 'shinytest2' with multiple inputs and user cases (Folder 'test' on this repo)</h5> 
<h5> here below a code example of unit-test </h5>

```R
library(shinytest2)

test_that("{shinytest2} recording: test_shiny", {
  app <- AppDriver$new(name = "test_shiny", height = 711, width = 1139)
  app$set_inputs(selection = c("Abraxas grossulariata", "Acer negundo"))
  app$set_inputs(selection = "Abraxas grossulariata")
  app$set_inputs(selection = character(0))
  app$set_inputs(customSwitch1 = TRUE)
  app$set_inputs(customSwitch1 = FALSE)
  app$expect_values()
})
```

<h2><b>Extras</b></h2>



<h4>Performance optimization skill</h4>

<h3><b>MySQL Database</b></h3>

<h5> The original dataset its up to 20gb, but data used in this development cointains the first 600.000 rows of the dataset, the raw data has been extracted using the wonderful Pandas doing every 100.000 lines in a loop, (Please see 'convert_csv.py' script), here below the function: </h5> 


```Python
def main():
    helper =  FileSplitter(FileSettings(
        file_name='/Users/pablorodriguez/Downloads/biodiversity-data/occurence.csv',
        row_size=100000
    ))
})
```
<h5> The raw data was uploaded to a mysql database using free aws schema, the free schema only allows a limited quantity of rows, thats why this exercise only contains 600.000 rounds, the script used for upload the data is in the repo (Please see 'save_on_mysql.R') </h5> 

<h5> The username and the password to access to the database is encrypted, with the use of 'safer' package, the database schema and the max num of rows  </h5> 


![image](https://user-images.githubusercontent.com/113043356/189261506-24af0dee-be11-452d-acfa-a8c83161c1d2.png)





<h4>Infrastructure skill</h4>
<h3><b>AWS EC2 Ubuntu Server </b></h3>

<h5> The app is working into a  ec2 ubuntu server from free aws schema, was released using "shinyserver", the instance have limited resources (ram and cpu), but have a good performance in production, some packages have to be installed from ubuntu console because they have many dependencies, the security group its open and the instance is open to the internet</h5> 

![image](https://user-images.githubusercontent.com/113043356/189264002-dc97fe03-7978-4085-91f4-c5ffaa30b1a8.png)

<h5> The URL of the app is : http://34.201.151.75:3838/test_shiny/ </h5> 

<h3><b> Plumber API </b></h3>

<h5> The app request data to the database using an API, this api uses a docker container allowed also in a ec2 ubuntu server, the recipe to buid this docker its on the dockerfile (see dockerfile in repo), the api uses the package RMySQL to establish a connection with a pool and request the data with a query, this api was tested with postman </h5> 

<h4><b> Docker Container </b></h4>
<h5> Container image and specifications</5>

![image](https://user-images.githubusercontent.com/113043356/189266529-0d474f19-4784-4509-aecd-13e1e56f111f.png)



<h4><b> The API uses a connection who encrypts the password using the library 'safer' </b></h4>

```R
get_query = function(query){
  mydb = {try_default(dbConnect(
    RMySQL::MySQL(),
    host = "database-1.ckd1e3sk7dwp.us-east-1.rds.amazonaws.com",
    user = "admin",
    password =decrypt_string("hUtjYeT9C5cSg9LAEuXhreKc1x/m+A0E8A==",codifier),
    dbname="ab"),1,quiet = T)}
    }
```
<h5> function get_query</5>

<h4><b> The app request data to database using the api, and the api makes the request using the following script </b></h4>

```R
# Read SQL query or database table into a DataFrame
# parameters
# query: str SQL query to be executed or a table name.

get_query <- function(query){
  #' @description Read SQL query or database table into a DataFrame
  #' @param query: str SQL query to be executed or a table name.
  
  request <- GET("http://54.159.47.24:8000/echo",
                 query = list(n=query),
                 encode = "json")
  data <- content(request, as = 'text', encoding = 'UTF-8')
  result <- as.data.frame(fromJSON(data))
  return(result)
}
```

<h4><b> The ubuntu server where the docker is loaded only allow connections from the aws ec2 instance where the app is working, the request return a json </b></h4>


<h3><b> And thats it !!! </b></h3>

<h4><b> This is the readme file for this development, if you have any doubts do not hesitate, just contact me!!  pablorodriguezcv@gmail.com, hope to see you soon </b></h4>

<h3><b> Pablo Rodríguez </b></h3>


