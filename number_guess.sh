#!/bin/bash
#!/bin/bash
# This is a useless comment
# This is a useless comment
# This is a useless comment

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

USER_RESULT=$($PSQL "SELECT user_id, games_played, best_game FROM users WHERE username='$USERNAME'")

if [[ -z $USER_RESULT ]]; then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
else
  IFS="|" read USER_ID GAMES_PLAYED BEST_GAME <<< "$USER_RESULT"
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
echo "Guess the secret number between 1 and 1000:"

NUMBER_OF_GUESSES=0

while true; do
  read GUESS

  if ! [[ $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi

  ((NUMBER_OF_GUESSES++))

  if (( GUESS == SECRET_NUMBER )); then
    echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
    break
  elif (( GUESS > SECRET_NUMBER )); then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi
done

GAMES_PLAYED=$((GAMES_PLAYED + 1))

if [[ -z $BEST_GAME || $NUMBER_OF_GUESSES -lt $BEST_GAME ]]; then
  BEST_GAME=$NUMBER_OF_GUESSES
fi

UPDATE_USER_RESULT=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED, best_game=$BEST_GAME WHERE user_id=$USER_ID")
INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $NUMBER_OF_GUESSES)")
