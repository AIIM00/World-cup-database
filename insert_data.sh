
#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi


# Do not change code above this line. Use the PSQL variable above to query your database.
$PSQL "TRUNCATE TABLE games, teams RESTART IDENTITY;"

#Insert unique teams
#year,round,winner,opponent,winner_goals,opponent_goals
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT W_GOALS O_GOALS
do
if [[ $YEAR != 'year' ]]
then 
#Insert winner team if not exists
WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
if [[ -z $WINNER_ID ]]
then
  RESULT_WINNER=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
  if [[ $RESULT_WINNER == 'INSERT 0 1' ]]
  then
    echo Inserted into teams, $WINNER
  fi
fi

#Insert opponent team if not exists
OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name ='$OPPONENT'")
if [[ -z $OPPONENT_ID ]]
then
  RESULT_OPPONENT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
   if [[ $RESULT_OPPONENT == 'INSERT 0 1' ]]
  then
    echo Inserted into teams, $OPPONENT
  fi
fi
#Get winner_id and opponent_id
WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

#INSERT year, round,winner,opponent,winner_goals,opponent_goals
if [[ -n $WINNER_ID && -n $OPPONENT_ID ]]
then 
  INSERT_GAMES_RESULT=$($PSQL "INSERT INTO games(year,round, winner_id, winner_goals, opponent_goals, opponent_id) VALUES($YEAR, '$ROUND', $WINNER_ID,  $W_GOALS,$O_GOALS, $OPPONENT_ID)")
  if [[ $INSERT_GAMES_RESULT == 'INSERT 0 1' ]]
  then
    echo "Inserted into games: $YEAR $ROUND - $WINNER ($W_GOALS) vs $OPPONENT ($O_GOALS)"

  fi
else
  echo "Error: Could not find team IDs for $WINNER or $OPPONENT"
fi

fi
done
