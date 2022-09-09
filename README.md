<h1><b>Shiny for Visualize Species</b></h1>
<h5> The scope of this repo is to explain the develop proccess of a Shiny app to visualize information about species,  the data comes from the Global Biodiversity Information Facility, at first there is a explanation about the tool, how it works and his features, after that will be a summary of the business/technical requirements and the infrastructure used for this case</h5>


<h4>this app it's allowed in <a href="url">http://34.201.151.75:3838/test_shiny/</a><h4>

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

<p><em>-Add readme that will help potential future developers of this app</em></p>

<h5> You're reading the readme file</h5>

<p><em>-Deploy the app to shinyapps.io</em></p>

<h5> The app is deployed into a aws ec2 spot machine file</h5>





