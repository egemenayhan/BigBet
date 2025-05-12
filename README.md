BigBet

Important Note: I had some questions about mostly API but since it was weekend did not wait for the reply so I had to assume some of the answers. Talked with Ayse Gul she said its ok as is team will tell if there is anything missing to save time. If there is anything misunderstood or missing please contact me so I can fix/add parts you asked. Tried to cover case study as much as possible.

I assumed we can use hardcoded sport key to fetch events. No pagination needed since API does not provide anything for it. There are time frame parameters I assumed setting commenceTimeFrom is enough to use API`s default time frame. Events endpoint does not have odds in it so I used Odds enpoint for the list for less request. There was no search endpoint in API doc so we are searching locally on the list.

Features:
- Event list based on hardcoded sport key with only commenceTimeFrom parameter
- You can bet directly from list by tapping odds
- Search events by team name
- Event detail page with bet actions
- See placed bets in cart and remove if you want
- Unit tests
- Error handling on list
- Analytics integration that supports multiple provider
- Color theme support

Used MVVM with clean architecture.
Made it reactive when possible with combine.
