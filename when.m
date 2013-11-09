%% A simple function that returns a string of the current date and time.
% Useful for logging in script files.
%
%
% ARGUMENTS:
%          none
%
% OUTPUT: 
%          date_and_time -- a string 
%
% REQUIRES: 
%          none
%
% USAGE:
%{
      %For logging of scripts, for example:
      disp(['Script started: ' when()])
      %Then do some stuff, before:
      disp(['Script ended: ' when()])
%}
%


function date_and_time = when()
  CurrentTime = clock;
  Year = num2str(CurrentTime(1));
  Month = num2str(CurrentTime(2));
  Day = num2str(CurrentTime(3));
  Hour = num2str(CurrentTime(4));
  Minute = num2str(CurrentTime(5)); 
  Second = num2str(CurrentTime(6));
  date_and_time = [Year '-' Month '-' Day ' at ' Hour ':' Minute ':' Second];
end %function when()
