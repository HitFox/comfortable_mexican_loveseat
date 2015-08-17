module WaitHelper
  def random_giphy
    giphy = ['https://media4.giphy.com/media/zhJPwGcqrGmas/200.gif', 
            'https://media2.giphy.com/media/oKVs1VY0MKfvO/200.gif',
            'https://media3.giphy.com/media/fyw72V4Lh5fy/200.gif',
            'https://media4.giphy.com/media/11QY4zzd3mqHe/200.gif',
            'https://media2.giphy.com/media/a6HJquvTVsBws/200.gif',
            'https://media3.giphy.com/media/u5eXlkXWkrITm/200.gif',
            'https://media1.giphy.com/media/iV0PzUj25DUTS/200.gif']
    giphy.sample
  end
end
