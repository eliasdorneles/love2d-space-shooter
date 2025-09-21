game.love:
	git archive --format=zip --output game.love main

game-web-build: game.love
	love.js game.love game-web-build --compatibility --title "Space Shooter"

release-web: game-web-build
	uvx ghp-import -m "Deploy to GitHub Pages" game-web-build
	git push origin gh-pages --force
