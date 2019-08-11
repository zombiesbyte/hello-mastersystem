//Dal1980 v1.0 Hello-MasterSystem
//August 2019 V1.0

fe.load_module("animate");
fe.load_module("conveyor");

class UserConfig {
     //Selection - changes the poster randomly each time a new cart is selected.
     //Layout - changes only once per system selection,
     //filename - allows you to specify a filename within posters directory
     //None - turns the poster off
     </ label="Poster", help="Choose the poster behaviour." options="selection,layout,filename,none" order=1 /> posterCfg="selection";
     </ label="SpecificPoster", help="Set a specific poster filename if filename option has been set for poster" order=2 /> specificPoster="tron.png";
     </ label="ChanceForChange", help="Choose the poster chance of change (percentage)." options="10,30,50,70,90" order=3 /> changeChance="90";
}

//thanks liquid8d for this method
function random(minNum, maxNum) {
    return floor(((rand() % 1000 ) / 1000.0) * (maxNum - (minNum - 1)) + minNum);
}


local dir = DirectoryListing( "posters" );
local postersArray = [];

foreach ( key, value in dir.results )
{
	postersArray.append(value);
}


local myConfig = fe.get_config();
fe.layout.width = 1280;
fe.layout.height = 1024;

//conveyor variables
local flx = fe.layout.width; 
local fly = fe.layout.height;
local flw = fe.layout.width;
local flh = fe.layout.height;

//background
local bg1 = fe.add_image("parts/background.png", 0, 0, 1280, 1024);



local posterFile = postersArray[random(0, postersArray.len()-1)];
local poster = fe.add_image(posterFile, -100, -250, 761, 1019);

if(myConfig["posterCfg"] == "filename"){
	posterFile = "posters/" + myConfig["specificPoster"];
	poster.file_name = posterFile;
}
else if(myConfig["posterCfg"] == "none"){
	poster.alpha = 0;
}

//title value
fe.layout.font = "SourceSerifPro-SemiBold";
local labelTitle = fe.add_text("[Title]", 670, 2, 381, 24);
labelTitle.align = Align.Left;

//favourites
local favHolder = fe.add_image("parts/favourite-off.png", 440, 899, 400, 118);


local logoBox = fe.add_artwork("box", 76, 475, 337, 530);

local tvBase = fe.add_image("parts/tv-base.png", 446, 270, 834, 683);
local snapBox = fe.add_artwork("snap", 539, 397, 640, 479);
local tvMask = fe.add_image("parts/tv-mask.png", 446, 270, 834, 683);
local tvScreen = fe.add_image("parts/tv-screen.png", 446, 270, 834, 683);
local mug = fe.add_image("parts/mug.png", 605, 122, 271, 222);
local console = fe.add_image("parts/ms.png", 458, 856, 826, 195);


//getFavs returns the image needed to represent the state of the favourite
function getFavs(index_offset) {
    if(fe.game_info( Info.Favourite, 0 ) == "1") return "parts/favourite-on.png";
    else return  "parts/favourite-off.png";
}

function getNewPoster(index_offset){
	if(myConfig["posterCfg"] == "selection"){
		if(random(1, 100) < myConfig["changeChance"].tofloat()){
			posterFile = postersArray[random(0, postersArray.len()-1)];
			return posterFile;
		}
		return posterFile;
	}
	return posterFile;
}

// wheel
local wheel_x = [  -999, -794, -513, -232,   49,  330,  611,  892, 1173, 1454, 1735, ];
local wheel_y = [   150,  150,  150,  150,  150,  150,  150,  150,  150,  150,  150, ];
local wheel_w = [   177,  177,  177,  177,  177,  177,  177,  177,  177,  177,  177, ];
local wheel_h = [   191,  191,  191,  191,  191,  191,  191,  191,  191,  191,  191, ];
local wheel_a = [     0,    0,   50,  100,  150,  200,  255,  200,  150,  100,    0, ];
local wheel_r = [     0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0, ];

local num_arts = 10;

class WheelEntry extends ConveyorSlot {
     
     constructor() {
          base.constructor( ::fe.add_artwork("logo"));
     }

     function on_progress( progress, var ) {
          local p = progress / 0.1;
          local slot = p.tointeger();
          p -= slot;
          slot++;

          if ( slot <= 0 ) slot=0;
          if ( slot >= 9 ) slot=9;

          if(m_obj.file_name == ""){
               m_obj.file_name = "parts/no_image.png";
          }
          m_obj.x = wheel_x[slot] + p * ( wheel_x[slot+1] - wheel_x[slot] );
          m_obj.y = wheel_y[slot] + p * ( wheel_y[slot+1] - wheel_y[slot] );
          m_obj.width = wheel_w[slot] + p * ( wheel_w[slot+1] - wheel_w[slot] );
          m_obj.height = wheel_h[slot] + p * ( wheel_h[slot+1] - wheel_h[slot] );
          m_obj.rotation = wheel_r[slot] + p * ( wheel_r[slot+1] - wheel_r[slot] );
          m_obj.alpha = wheel_a[slot] + p * ( wheel_a[slot+1] - wheel_a[slot] );
          m_obj.preserve_aspect_ratio = true;
          //if() m_obj.rotation = 45 + p * ( wheel_a[slot+1] - wheel_a[slot] );
     }
};

local wheel_entries = [];
for ( local i=0; i<num_arts/2; i++ )
wheel_entries.push( WheelEntry() );

local remaining = num_arts - wheel_entries.len();

// we do it this way so that the last wheelentry created is the middle 
// one showing the current selection (putting it at the top of the draw order)
for ( local i=0; i<remaining; i++ )
wheel_entries.insert( num_arts/2, WheelEntry() );

local conveyor = Conveyor();
conveyor.set_slots( wheel_entries );
conveyor.transition_ms = 55;

function simpleCat( ioffset ) {
  local m = fe.game_info(Info.Category, ioffset);
  local temp = split( m, " / " );
  if(temp.len() > 0) return temp[0];
  else return "";
}

fe.add_transition_callback( "update_my_list" );
function update_my_list( ttype, var, ttime ) {
    favHolder.file_name = getFavs(0);
    if(ttype == Transition.StartLayout){
        favHolder.file_name = getFavs(0);
    }
    else if(ttype == Transition.EndNavigation){
        favHolder.file_name = getFavs(0);
        poster.file_name = getNewPoster(0);
    } 
    return false;
}


//we need to apply these after effects here for z-ordering

local mugShade = fe.add_image("parts/mug-shade.png", 606, 123, 175, 225);
local etPhoneHome = fe.add_image("parts/et.png", 301, 830, 134, 180); 

//game number
fe.layout.font = "SourceSerifPro-SemiBold";
local labelListEntry = fe.add_text("[ListEntry] / [ListSize]", 582, 935, 300, 24);
labelListEntry.align = Align.Left;
labelListEntry.style = Style.Italic;