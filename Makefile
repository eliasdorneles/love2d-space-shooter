game.love:
	git archive --format=zip --output game.love main

game: game.love
	love.js game.love game --compatibility --title "Space Shooter"
