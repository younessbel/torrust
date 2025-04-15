const express = require("express");
const mongoose = require("mongoose");
require("dotenv").config();

const app = express();
const PORT = process.env.PORT || 4000;


app.use(express.json());


mongoose.connect(process.env.MONGO_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
  .then(() => console.log(" MongoDB Connected"))
  .catch((err) => console.error(" MongoDB Connection Error:", err));

   
  
  app.use(require("./routes/signup")); 

  app.use(require("./routes/login"));

const resetRoutes = require('./routes/reset');
app.use('/auth', resetRoutes);

app.listen(PORT, () => {
  console.log(` Server is running on port ${PORT}`);
});