const BloodBank = require('../models/BloodBank');
const BloodStock = require('../models/BloodStock');
const Donation = require('../models/Donation');
const Distribution = require('../models/Distribution');
const HospitalBloodRequest = require('../models/HospitalBloodRequest');

const registerBloodBank = async (req, res) => {
  try {
    const existingBloodBank = await BloodBank.findOne({ 
      $or: [{ email: req.body.email }, { registrationNumber: req.body.registrationNumber }]
    });
    
    if (existingBloodBank) {
      return res.status(400).json({ message: 'Blood bank already exists with this email or registration number' });
    }

    const bloodBank = new BloodBank(req.body);
    await bloodBank.save();
    res.status(201).json({ message: 'Blood bank registered successfully' });
  } catch (error) {
    res.status(400).json({ message: 'Registration failed', error: error.message });
  }
};

const _seedPatanBank = async () => {
  try {
    const targetId = "69201ebb64de9caf8ba8f2f0"; 
    
    let bank = await BloodBank.findById(targetId);
    if (!bank) {
      const bankData = {
        _id: targetId,
        bloodBankName: "Patan Blood bank ",
        email: "patanbloodbank@gmail.com",
        phoneNumber: "985236751",
        registrationNumber: "6171-282-13",
        fullAddress: "Patan, balkumari ",
        city: "lalitpur ",
        district: "Kathmandu",
        contactPerson: "head officer",
        designation: "no",
        storageCapacity: 100,
        emergencyService24x7: true,
        componentSeparation: false,
        apheresisService: false,
        password: "bloodbank123"
      };
      
      bank = new BloodBank(bankData);
      await bank.save();
      console.log("Seeded Patan Blood Bank");
    }

    const stockCount = await BloodStock.countDocuments({ bloodBank: targetId });
    if (stockCount === 0) {
      const dummyStocks = [
        { bloodBank: targetId, bloodGroup: 'A+', units: 25, expiryDate: new Date('2025-12-31') },
        { bloodBank: targetId, bloodGroup: 'A-', units: 10, expiryDate: new Date('2025-12-31') },
        { bloodBank: targetId, bloodGroup: 'B+', units: 30, expiryDate: new Date('2025-12-31') },
        { bloodBank: targetId, bloodGroup: 'B-', units: 5, expiryDate: new Date('2025-12-31') },
        { bloodBank: targetId, bloodGroup: 'O+', units: 40, expiryDate: new Date('2025-12-31') },
        { bloodBank: targetId, bloodGroup: 'O-', units: 15, expiryDate: new Date('2025-12-31') },
        { bloodBank: targetId, bloodGroup: 'AB+', units: 8, expiryDate: new Date('2025-12-31') },
        { bloodBank: targetId, bloodGroup: 'AB-', units: 3, expiryDate: new Date('2025-12-31') },
      ];
      
      await BloodStock.insertMany(dummyStocks);
      console.log("Seeded stocks for Patan Blood Bank");
    }
  } catch (error) {
    console.error("Seeding failed:", error);
  }
};

const getAllBloodBanks = async (req, res) => {
  try {
    await _seedPatanBank();

    const bloodBanks = await BloodBank.find().lean();

    const bloodBanksWithInventory = await Promise.all(bloodBanks.map(async (bank) => {
      const stocks = await BloodStock.find({ bloodBank: bank._id });
      
      const inventory = {};
      stocks.forEach(stock => {
        const group = stock.bloodGroup;
        if (!inventory[group]) inventory[group] = 0;
        inventory[group] += stock.units;
      });

      return { ...bank, inventory };
    }));

    res.json(bloodBanksWithInventory);
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

const getBloodBankProfile = async (req, res) => {
  try {
    const bankId = req.params.id;
    const bank = await BloodBank.findById(bankId).lean();
    
    if (!bank) {
      return res.status(404).json({ message: 'Blood bank not found' });
    }

    const stocks = await BloodStock.find({ bloodBank: bankId });
    const inventory = {};
    stocks.forEach(stock => {
      const group = stock.bloodGroup;
      if (!inventory[group]) inventory[group] = 0;
      inventory[group] += stock.units;
    });

    res.json({ ...bank, inventory });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

const recordDonation = async (req, res) => {
  try {
    const bloodBankId = req.params.id;
    const { donorId, donorName, bloodGroup, units, contactNumber, address, donationDate } = req.body;

    if (!bloodBankId || !bloodGroup || !units) {
      return res.status(400).json({ message: 'Missing required fields' });
    }

    const donation = new Donation({
      bloodBank: bloodBankId,
      donor: donorId, 
      donorName,
      bloodGroup,
      units,
      contactNumber,
      address,
      donationDate: donationDate || new Date()
    });
    await donation.save();

    let stock = await BloodStock.findOne({ bloodBank: bloodBankId, bloodGroup: bloodGroup });
    
    if (stock) {
      stock.units += parseInt(units);
      await stock.save();
    } else {
      stock = new BloodStock({
        bloodBank: bloodBankId,
        bloodGroup,
        units: parseInt(units),
        expiryDate: new Date(Date.now() + 35 * 24 * 60 * 60 * 1000) 
      });
      await stock.save();
    }

    res.status(201).json({ message: 'Donation recorded and stock updated', donation, stock });

  } catch (error) {
    console.error('Record donation error:', error);
    res.status(400).json({ message: 'Failed to record donation', error: error.message });
  }
};

const getDonations = async (req, res) => {
  try {
    const donations = await Donation.find({ bloodBank: req.params.id }).sort({ donationDate: -1 });
    res.json(donations);
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

const recordDistribution = async (req, res) => {
  try {
    const bloodBankId = req.params.id;
    const { requestId, hospitalId, hospitalName, bloodGroup, units, dispatchDate, courierName, vehicleNumber, driverContact } = req.body;

    const unitsToDistribute = parseInt(units);
    if (!bloodBankId || !hospitalId || !bloodGroup || !unitsToDistribute) {
      return res.status(400).json({ message: 'Missing required fields' });
    }

    // Check stock
    const stock = await BloodStock.findOne({ bloodBank: bloodBankId, bloodGroup: bloodGroup });
    if (!stock || stock.units < unitsToDistribute) {
      return res.status(400).json({ message: `Insufficient stock for ${bloodGroup}` });
    }

    // Create Distribution
    const distribution = new Distribution({
      bloodBank: bloodBankId,
      hospital: hospitalId,
      hospitalName,
      bloodGroup,
      units: unitsToDistribute,
      dispatchDate: dispatchDate || new Date(),
      courierName,
      vehicleNumber,
      driverContact
    });
    await distribution.save();

    // Update Stock
    stock.units -= unitsToDistribute;
    await stock.save();

    // Update Request Status if linked
    if (requestId) {
      await HospitalBloodRequest.findByIdAndUpdate(requestId, { status: 'fulfilled' });
    }

    res.status(201).json({ message: 'Distribution recorded and stock updated', distribution, remainingStock: stock });

  } catch (error) {
    console.error('Record distribution error:', error);
    res.status(400).json({ message: 'Failed to record distribution', error: error.message });
  }
};

const getDistributions = async (req, res) => {
  try {
    const distributions = await Distribution.find({ bloodBank: req.params.id }).sort({ dispatchDate: -1 });
    res.json(distributions);
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

const getBloodBankRequests = async (req, res) => {
  try {
    // Fetch requests where requestedFrom is 'blood_bank' (or all hospital requests)
    // Assuming for now we return all pending/approved hospital requests
    const requests = await HospitalBloodRequest.find({ 
      requestedFrom: 'blood_bank'
    })
    .populate('hospital')
    .sort({ createdAt: -1 });
    
    res.json(requests);
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

const seedData = async (req, res) => {
  await _seedPatanBank();
  res.json({ message: 'Seeding attempt complete' });
};

module.exports = { 
  registerBloodBank, 
  getAllBloodBanks, 
  getBloodBankProfile, 
  seedData,
  recordDonation,
  getDonations,
  recordDistribution,
  getDistributions,
  getBloodBankRequests
};
