<html>
<head>
    <title>Welcome to My Web Page</title>
    <style>
        body {
            font-family: 'Roboto', sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f0f0f0;
        }
        .container {
            max-width: 600px;
            margin: 0 auto;
            background-color: #fff;
            padding: 20px;
            border-radius: 5px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
        }
        h1 {
            color: #333;
            font-family: 'Montserrat', sans-serif;
        }
        p {
            margin-bottom: 20px;
            line-height: 1.5;
        }
        .phpinfo-link,
        .source-code-link {
            display: inline-block;
            padding: 10px 20px;
            background-color: #007bff;
            color: #fff;
            text-decoration: none;
            border-radius: 4px;
        }
        .source-code-link {
            margin-left: 10px;
        }
    </style>
    <link href="https://fonts.googleapis.com/css?family=Montserrat:400,700|Roboto:400,700" rel="stylesheet">
</head>
<body>
    <div class="container">
        <h1>Welcome to My Web Page</h1>
        <p>This is the default index page.</p>
        <p>For more information about PHP configuration, click the button below:</p>
        <a class="phpinfo-link" href="phpinfo.php">View PHP Info</a>
        <a class="source-code-link" href="https://github.com/thesuhu/docker-alpine-nginx-php" target="_blank">View Source Code</a>
    </div>
</body>
</html>
