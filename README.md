# Производительность iOS-приложений
Сделаны все обязательные пункты и частично пункты со звездочкой.

## Урок 1. Параллельное программирование. Thread.
На этом курсе вы добавите в приложение, разработанное на прошлом уроке, ленту новостей. Лента будет разрабатываться весь курс, и в процессе изучения новых технологий вы будете улучшать ее производительность.
1. Добавить еще одну вкладку в приложение.
2. На новой вкладке добавить UITableViewController для отображения ленты новостей.
3. В UITableViewController добавить прототип ячейки для новости типа post.
4. *Добавить также прототип ячейки для новости типа photo.

- Ячейки обязательно должны содержать автора новости, его аватар, количество лайков и комментариев, репостов и просмотров.
- Ячейка поста должна содержать текст поста.
- *Ячейка фото должна содержать фото.
- Доставать фото из вложений не надо.
- Пока можно обойтись примерными прототипами и доработать их позднее.
- Высота ячеек должна быть стандартна. Текст должен прокручиваться, если его много.

## Урок 2. Параллельное программирование. GCD
1. Создать сервис для получения ленты новостей из ВК.
2. Добавить запрос для получения новостей типа post.
3. Создать класс для представления новости типа post.
4. *Добавить запрос для получения новостей типа photo.
5. *Создать класс для представления новости типа photo.

Вынести работу с сетью и парсинг в глобальную очередь для вк-сервиса.

## Урок 3. Параллельное программирование. NSOperation
1. Работа над проектом «Приложение для ВКонтакте».
2. Добавлена работа с Operations в списке групп: контроллер GroupTableViewController. Описано все в GetGroupsListOperations.swift

## Урок 4. Асинхронный код. Futures/Promises
1. Самостоятельно изучить документацию PromiseKit, познакомиться с операторами when, race, recover, attempt.
2. Перевести на PromiseKit отправку сетевого запроса на получение друзей, или групп пользователя. Другой workflow в зависимости от того, что у вас переведено на Operations. 


