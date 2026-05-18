use zadanie2;

db.createCollection("trips", {
   validator: {
      $jsonSchema: {
         bsonType: "object",
         required: [ "title", "price", "organizer" ],
         properties: {
            title: { bsonType: "string" },
            price: { bsonType: "number", minimum: 0 },
            organizer: {
               bsonType: "object",
               required: [ "company_id", "company_name" ]
            },
            booked_by: {
               bsonType: "array",
               items: { bsonType: "int" }
            },
            reviews: { bsonType: "array" }
         }
      }
   }
});

db.companies.insertMany([
  { _id: 1, name: "Góry-Travel", contact: "kontakt@gory-travel.pl" },
  { _id: 2, name: "Morze-Adventures", contact: "biuro@morze.pl" }
]);

db.people.insertMany([
  { _id: 101, firstname: "Jan", lastname: "Kowalski", email: "jan@example.com" },
  { _id: 102, firstname: "Anna", lastname: "Nowak", email: "anna@example.com" },
  { _id: 103, firstname: "Piotr", lastname: "Zalewski", email: "piotr@example.com" }
]);

db.trips.insertMany([
  {
    _id: 1001,
    title: "Weekend w Tatrach",
    price: 450,
    organizer: {
      company_id: 1,
      company_name: "Góry-Travel"
    },
    booked_by: [101, 102],
    reviews: [
      { person_id: 101, rating: 5, comment: "Świetna wycieczka, polecam!" },
      { person_id: 102, rating: 4, comment: "Pogoda nie dopisała, ale organizacja super." }
    ]
  },
  {
    _id: 1002,
    title: "Rejs po Bałtyku",
    price: 1200,
    organizer: {
      company_id: 2,
      company_name: "Morze-Adventures"
    },
    booked_by: [103],
    reviews: []
  }
]);

db.trips.aggregate([
  { $match: { _id: 1001 } },
  { $project: {
      _id: 0,
      title: 1,
      organizerName: "$organizer.company_name",
      totalBookings: { $size: "$booked_by" },
      averageRating: { $avg: "$reviews.rating" }
    }
  }
]);

db.trips.aggregate([
  { $match: { _id: 1001 } },
  { $lookup: {
      from: "people",
      localField: "booked_by",
      foreignField: "_id",
      as: "participants_details"
    }
  },
  { $project: {
      title: 1,
      "participants_details.firstname": 1,
      "participants_details.lastname": 1
    }
  }
]);

db.trips.updateOne(
  { _id: 1002 },
  { $push: { booked_by: 101 } }
);