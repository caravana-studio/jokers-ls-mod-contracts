echo -e "\n[INFO] Creating a new game..."
sozo execute game_system create_game -c 1 --wait --world 0x37578f01e123327fb366fc6e2224f4be4e44234d682855e1326363b57444b88
sleep 3
echo -e "\n[INFO] Game created successfully. Waiting 3 seconds before selecting deck..."

echo -e "\n[INFO] Selecting deck for the game..."
sozo execute game_system select_deck -c 1,0 --wait --world 0x37578f01e123327fb366fc6e2224f4be4e44234d682855e1326363b57444b88
sleep 3
echo -e "\n[INFO] Deck selected successfully. Waiting 3 seconds before selecting special cards..."

echo -e "\n[INFO] Selecting special cards for the deck..."
sozo execute game_system select_special_cards -c 1,1,1 --wait --world 0x37578f01e123327fb366fc6e2224f4be4e44234d682855e1326363b57444b88
sleep 3
echo -e "\n[INFO] Special cards selected successfully. Waiting 3 seconds before selecting modifier cards..."

echo -e "\n[INFO] Selecting modifier cards for the deck..."
sozo execute game_system select_modifier_cards -c 1,1,1 --wait --world 0x37578f01e123327fb366fc6e2224f4be4e44234d682855e1326363b57444b88
sleep 3
echo -e "\n[INFO] Modifier cards selected successfully. Setup complete!"


# sozo execute game_system play -c 1,5,0,1,2,3,4,5,100,100,100,100,100 --wait --world 0x37578f01e123327fb366fc6e2224f4be4e44234d682855e1326363b57444b88
# sozo execute game_system end_turn -c 1 --wait --world 0x37578f01e123327fb366fc6e2224f4be4e44234d682855e1326363b57444b88 
