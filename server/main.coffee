# Main server

Meteor.startup ->
  console.log "#Questions: " + @Questions.find().count()
  if Questions.find().count() == 0
    Questions.insert
      sound: 'EM-Finale_DK-DE',
      correct_answer: 'A',
      alternatives: [
          {
              name: 'A',
              text: 'EM Finale Tyskland 1992'
          },
          {
              name: 'B',
              text: 'VM Finale Brasil 1990'
          },
          {
              name: 'C',
              text: 'EM Semi Tyskland 1983'
          },
          {
              name: 'D',
              text: 'EM Semi Tyskland 2000'
          }
      ]
    Questions.insert
      sound: 'EM-Kval_DK-GB',
      correct_answer: 'B',
      alternatives: [
          {
              name: 'A',
              text: 'VM Finale Brasil 1990'
          },
          {
              name: 'B',
              text: 'EM Kval. England 1983'
          },
          {
              name: 'C',
              text: 'EM Semi Tyskland 1983'
          },
          {
              name: 'D',
              text: 'EM Semi Tyskland 2000'
          }
      ]
    Questions.insert
      sound: 'EM-Semi_DK-NL',
      correct_answer: 'C',
      alternatives: [
          {
              name: 'A',
              text: 'EM Finale Tyskland 1983'
          },
          {
              name: 'B',
              text: 'VM Finale Brasil 1990'
          },
          {
              name: 'C',
              text: 'EM Semi Holland 1992'
          },
          {
              name: 'D',
              text: 'EM Semi Tyskland 2000'
          }
      ]
    Questions.insert
      sound: 'OL-Semi_DK-HU',
      correct_answer: 'D',
      alternatives: [
          {
              name: 'A',
              text: 'EM Finale Tyskland 1983'
          },
          {
              name: 'B',
              text: 'VM Finale Brasil 1990'
          },
          {
              name: 'C',
              text: 'EM Semi Tyskland 1983'
          },
          {
              name: 'D',
              text: 'OL Semi Ungarn 1960'
          }
      ]
    Questions.insert
      sound: 'VM-Kvart_DK-BR',
      correct_answer: 'A',
      alternatives: [
          {
              name: 'A',
              text: 'VM Kvart Brasiliel 1998'
          },
          {
              name: 'B',
              text: 'VM Finale Brasil 1990'
          },
          {
              name: 'C',
              text: 'EM Semi Tyskland 1983'
          },
          {
              name: 'D',
              text: 'EM Semi Tyskland 2000'
          }
      ]
