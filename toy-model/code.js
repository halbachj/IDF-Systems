schools = []; //Overarching faculty of the courses
schools['HUM'] = [{"name":"History","places":16,"hours":8,"cx":100,"cy":300,"students":[]},{"name":"English","places":28,"hours":6,"cx":300,"cy":300,"students":[]},{"name":"Geography","places":20,"hours":6,"cx":200,"cy":150,"students":[]}];
schools['STEM'] = [{"name":"Botany","places":24,"hours":10,"cx":500,"cy":300,"students":[]},{"name":"Earth Sciences","places":19,"hours":8,"cx":700,"cy":300,"students":[]}];
schools['MED'] = [{"name":"Dentistry","places":32,"hours":32,"cx":100,"cy":500,"students":[]},{"name":"Nursing","places":26,"hours":34,"cx":300,"cy":500,"students":[]}];
schools['BUS'] = [{"name":"Management","places":18,"hours":8,"cx":500,"cy":500,"students":[]},{"name":"Accounting","places":25,"hours":10,"cx":700,"cy":500,"students":[]}];

intensity = []; //Contact time multipliers for different types of society activity
intensity['passive'] = 0.25;
intensity['sociable'] = 0.75;
intensity['interactive'] = 1.0;

interests = ['Debating','Politics','Earth Sciences','Gaming','Rugby','LGBT','Geography']; //Possible student interests
societies = [];
societies['Phil'] = {"color":"#669900","cy":100,"cx":500,"regular":{"hours":1,"type":"passive","activity":["Debating","Politics"]}};
societies['Joly'] = {"color":"#FF6600","cy":100,"cx":600,"regular":{"hours":1,"type":"passive","activity":["Earth Sciences"]}};
societies['Gamers'] = {"color":"#9999CC","cy":100,"cx":700,"regular":{"hours":2.5,"type":"interactive","activity":["Gaming"]}};
societies['Rugby'] = {"color":"#CC9999","cy":100,"cx":800,"regular":{"hours":4,"type":"interactive","activity":["Rugby"]}};
societies['LGBT'] = {"color":"#FF99FF","cy":100,"cx":900,"regular":{"hours":2,"type":"sociable","activity":["LGBT"]}};

colours = []; //Colour of each school when displayed
colours['HUM'] = '#ff0000';
colours['STEM'] = '#66CC00';
colours['MED'] = '#3333FF';
colours['BUS'] = '#cccc00';
colours["HUM-HUM"] = "#ff0000";
colours["STEM-STEM"] = "#66CC00";
colours["MED-MED"] = "#3333FF";
colours["BUS-BUS"] = "#cccc00";

students = []; //Array to hold student objects

friendships = []; //Array to hold friendships between students

memberships = []; //Array to hold student memberships of societies

totalContactHours = []; //Accumulated contact hours between pairs of students

tick = 0;


function bellCurve(){
	a = Math.random();
	b = Math.random();
	c = Math.random();
	z = (a + b + c) / 3;
	return z;
}
function clearAll(){
	var svg = document.getElementsByTagName('svg')[0]; //Get svg element
	svg.innerHTML = ''; //Empty the svg
	students = []; //Clear the array of students
	friendships = []; //Clear the array of friendships
	memberships = []; //Clear the array of friendships
	totalContactHours = [];
	document.getElementById('messages').innerHTML = '';
	tick = 0;
	num_interests = 0;
}

function swapLines(){ //For display purposes
	var friends = document.getElementById('show_friendships').checked;
	var out_friends = document.getElementById('show_outfriendships').checked;
	var members = document.getElementById('show_memberships').checked;

	const friends_lines = document.getElementsByClassName('friendship');
	const school_friends_lines = document.getElementsByClassName('school-friendship');
	const out_friends_lines = document.getElementsByClassName('out-friendship');
	const members_lines = document.getElementsByClassName('membership');

	for(let i=0;i<friends_lines.length;i++){
		if(friends){
			friends_lines[i].style.display = '';
		}
		else{
			friends_lines[i].style.display = 'none';
		}
	}
	for(let i=0;i<school_friends_lines.length;i++){
		if(out_friends){
			school_friends_lines[i].style.display = '';
		}
		else{
			school_friends_lines[i].style.display = 'none';
		}
	}
	for(let i=0;i<out_friends_lines.length;i++){
		if(out_friends){
			out_friends_lines[i].style.display = '';
		}
		else{
			out_friends_lines[i].style.display = 'none';
		}
	}
	for(let i=0;i<members_lines.length;i++){
		if(members){
			members_lines[i].style.display = '';
		}
		else{
			members_lines[i].style.display = 'none';
		}
	}
}

//Draws lines
function drawLine(xa,ya,xb,yb,colour,line_class,line_id){
	var svg = document.getElementsByTagName('svg')[0]; //Get svg element
	var newElement = document.createElementNS("http://www.w3.org/2000/svg", 'path'); //Create a path in SVG's namespace
	newElement.setAttribute("d","M "+xa+" "+ya+" L "+xb+" "+yb+""); //Set path's data -> + sign joins strings and variables
	newElement.style.stroke = colour; //Set stroke colour
	newElement.style.strokeWidth = "1px"; //Set stroke width
	newElement.style.position = "relative"; //Set stroke width
	newElement.style.zIndex = 1; //Set stroke width
	newElement.classList = line_class; //Set stroke width
	newElement.id = line_id; //Set stroke width
	svg.appendChild(newElement);
}
//Gets the student details
function studentDetails(num){
	student = students[num];
	alert("Clicked "+JSON.stringify(student));
}
num_interests = 0;
function addStudent(x,y,color,school,course){
	console.log("addStudent " + school);
	var svg = document.getElementsByTagName('svg')[0]; //Get svg element
	var newElement = document.createElementNS("http://www.w3.org/2000/svg", 'circle'); //Create a path in SVG's namespace
	var personality = Math.floor(Math.random() * 360);
	var extra = bellCurve();
	var studentNum = students.length;
	var m = Math.random();
	var course_interest = 0.75 + (m * 0.25);
	var studentInterests = [{"interest":schools[school][course].name,"str":course_interest}]; //Assume student is interested in their course (!)
	var studentMemberships = []; //Assume student is interested in their course (!)

  /*
   * Creating a new student
   * A students personality is determined by random on a scale between 0 and 360
   * A students extroversion is a bell curve
   * A student choose their course as an interest
   * 
   * Choosing new interests
   * go through all the available interests/societies
   * roll a dice from 0 to 0.9
   * if the interest selected is not the school and the dice roll was higher than 0.6
   *   pick up the new interest
   *   the dice roll is now the strength of that interest
   *
   *   join one of the societies if one exists that reflects that interest and it is not already joined
   */

	for(let i=0;i<interests.length;i++){
		m = Math.random() * 0.9;
		if(interests[i] != schools[school][course].name && m>0.6){
			studentInterests.push({"interest":interests[i],"str":m});
			num_interests++;
			//Join a society if there's one that reflects this interest and it's not already joined
			for(akey in societies){ //*How many societies do people join on average?
				soc = societies[akey];
				if(soc.regular.activity.indexOf(interests[i])>-1 || soc.regular.activity.indexOf(schools[school][course].name)>-1){
					if(!memberships[akey+"-"+studentNum]){
						studentMemberships.push(akey);
						memberships[akey+"-"+studentNum] = {"interest":interests[i]};
						drawLine(x,y,soc.cx,soc.cy,soc.color,'membership',akey+"-"+studentNum);
					}
				}
			}
		}
	}
	var student = {"personality":personality,"extra":extra,"emoCap":Math.round(extra * 10),"friends":0,"school":school,"course":course,"cx":x,"cy":y,"studentNum":studentNum,"studentInterests":studentInterests,"studentMemberships":studentMemberships};
	students.push(student);
	//Commented out - Console.log(student);
	newElement.setAttribute("r",2 + (6 * extra)); //Set circle radius
	newElement.setAttribute("cx",x); //Set circle radius
	newElement.setAttribute("cy",y); //Set circle radius
	newElement.setAttribute("id","student_" + studentNum); //Set circle radius
	newElement.style.fill = color; //Set stroke colour
	newElement.setAttribute("onclick","studentDetails("+studentNum+")");
	newElement.style.position = "relative"; //Set stroke width
	newElement.style.zIndex = 1000; //Set stroke width
	svg.appendChild(newElement);
}
function drawSociety(x,y,color,name){
	var svg = document.getElementsByTagName('svg')[0]; //Get svg element
	var newElement = document.createElementNS("http://www.w3.org/2000/svg", 'circle'); //Create a path in SVG's namespace
	newElement.setAttribute("r",30); //Set circle radius
	newElement.setAttribute("cx",x); //Set circle radius
	newElement.setAttribute("cy",y); //Set circle radius
	newElement.style.fill = color; //Set stroke colour
	newElement.setAttribute("onclick","societyDetails("+name+")");
	newElement.style.position = "relative"; //Set stroke width
	newElement.style.zIndex = 1000; //Set stroke width
	svg.appendChild(newElement);
	//*text
	var newTextElement = document.createElementNS("http://www.w3.org/2000/svg", 'text'); //Create a text in SVG's namespace
	var textContent = document.createTextNode(name);
	newTextElement.appendChild(textContent);
	newTextElement.setAttribute("x",x-15); //Set circle radius
	newTextElement.setAttribute("y",(y - 40)); //Set circle radius
	newTextElement.style.position = "relative"; //Set stroke width
	newTextElement.style.fill = 'black'; //Set stroke colour
	svg.appendChild(newTextElement);
}

function drawDots(cx, cy, r, dots, color, school, course){
	console.log("drawDots " + school);
	let center = {x: cx, y: cy}
	let radius = r;
	let amountOfDots = dots;
	for (let i = 0; i < amountOfDots; i++) {
		let x = radius * Math.sin(Math.PI * 2 * i / amountOfDots) + center.x;
		let y = radius * Math.cos(Math.PI * 2 * i / amountOfDots) + center.y;
		//Draw my dot in (x, y) or whatever
		addStudent(x,y,color,school,course);
	}
}
function drawSchools(){
	for(key in schools){
		console.log("Drawing school "+key);
		course = schools[key];
		for(i=0;i<course.length;i++){
			 drawDots(course[i].cx, course[i].cy, 75, course[i].places, colours[key], key, i); //Drawing dots in a circle
		}
	}
	for(key in societies){
		society = societies[key];
		drawSociety(society.cx,society.cy,society.color,key);
	}
	//Alert(students.length + "/" + num_interests);
}
function makeFriend(studentA, studentB, a, b){
	if(friendships[studentA.studentNum + "-" + studentB.studentNum] || friendships[studentB.studentNum + "-" + studentA.studentNum]){
		return false;
	}
	//*Could be added - effect of mutual friends? societies in common?
	
	var members = document.getElementById('use_memberships').checked;
	var persA = studentA.personality;
	var persB = studentB.personality;
	var extraA = studentA.extra;
	var extraB = studentB.extra;
	var numA = studentA.studentNum;
	var numB = studentB.studentNum;
	if(studentA.school == studentB.school){

    /*
     * Determine contact hours 
     * if both students share the same course the contact hours get increased by 2
     * But if both students are still in the same faculty/school they get 2 contact hours in total ( I think this should be random tho )
     * If they share neither the same school or course they get 1 contact hour (should be zero. Maybe randomly get one)
     *
     * Influence of societies
     * If both students share the same society they will get 2 additional contact hours
     *
     * The effectiveness of the contact hours is determined by following formula:
     * t_eff = sqrt(t_contact) * (extroversion_A + extroversion_B)
     *
     * The effect of personality
     * Determine the personality difference and divide it by the total contact hours.
     * k = personality_diff / t_eff
     *
     * Roll a 5 sided dice against this. If the difference is smaller than the rolled number a friendship is made.
     *
      */

		if(studentA.course == studentB.course){
			contactHours = schools[studentA.school][studentA.course].hours + 2; //When share school and course
		}
		else{ //Simple place holders for societies and sports clubs
			contactHours = 2; //When share school but not course 
		}
	}
	else{
		contactHours = 1; //When share neither school nor course
	}
	for(mkey in societies){
		if(memberships[mkey+"-"+numA] && memberships[mkey+"-"+numB] && members){
			contactHours += 2;
		}
	}
	var effectiveContactHours = Math.pow(contactHours,0.5) * (extraA + extraB); //So the effect of contact hours diminishes
	pairKey = a + "-" + b;
	if(!totalContactHours[pairKey]){totalContactHours[pairKey] = effectiveContactHours;}
	else{totalContactHours[pairKey] += effectiveContactHours;}
	var diff = 360 - Math.abs(persA - persB);
	var diff2 = Math.abs(persA - persB);
	diff = diff / totalContactHours[pairKey];
	var q = Math.random() * 5; //Roll against personality difference for friendship - simple to become more complex
	//CO - Console.log(persA + "\t" + persB + "\t" + diff + "\t" + diff2);

	if(diff < q){
		return true;
	}
	else{
		return false;
	}
}
function checkFriendships(){
	var new_friends = 0; //Number of new friendsships made this tick
	var new_cross_friends = 0; //Number of new cross-course friendships made this tick
	tick++;
	for(a=0;a<students.length;a++){
		for(b=0;b<students.length;b++){
			//If the students have available capacity for new friends
			if(a != b && students[a].friends<=students[a].emoCap && students[b].friends<=students[b].emoCap){
				var isFriend = makeFriend(students[a],students[b], a, b); //Pass student objects and their students array index 
				if(isFriend){
					colour = "#666";
					fset = '';
					if(students[a].school == students[b].school && students[a].course == students[b].course){
						fset = 'friendship';
					}
					else if(students[a].school == students[b].school){
						fset = 'school-friendship';
					}
					else{
						fset = 'out-friendship';
					}
					var fid = "fr_" + students[a].studentNum + "_" + students[b].studentNum; //Unique friendship line id
					new_friends++;
					if(students[a].school != students[b].school || students[a].course != students[b].course){new_cross_friends++;}
					students[a].friends++;
					students[b].friends++;
					friendships[students[a].studentNum + "-" + students[b].studentNum] = {"id":fid,"formed":tick,"type":fset};

					if(colours[students[a].school + "-" + students[b].school]){colour = colours[students[a].school + "-" + students[b].school];}
					drawLine(students[a].cx,students[a].cy,students[b].cx,students[b].cy,colour,fset,fid); 
				}
			}
		}
	}
	var broken = 0;
	var tmp_friendships = [];
	for(key in friendships){
		//Console.log(friendships[key]);
		//Equal chance of breaking any friendship? or depends on length of friendship?
		var d = Math.random();
		var fr_len = tick - friendships[key].formed;//length of friendship
		d = d - (fr_len * 0.01);
		if(d > 0.95){
			console.log("Breaking friendship " + key + " with " + d);
			ids = key.split("-"); //Split to get the two student ids
			students[ids[0]].friends--; //Deincrement student number of friends
			students[ids[1]].friends--;
			el = document.getElementById(friendships[key].id);
			el.remove();
			friendships[key] = null;
			broken++;
		}
		else{
			tmp_friendships[key] = friendships[key];
		}
	}
	friendships = tmp_friendships;
	el = document.getElementById('messages');
	el.innerHTML = tick + "\t" + new_friends + "\t" + new_cross_friends + "\t" + broken + "\n" + el.innerHTML;
}
