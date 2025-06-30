import { Injectable } from "@nestjs/common";
import { InjectModel } from "@nestjs/mongoose";
import { Model } from "mongoose";
import { Doctor, DoctorDocument } from "../doctor/doctor.schema";
import { slot, SlotDocument } from "../doctor/schema/slot.schema";
import { appoinment, appoinmentDocument } from "src/doctor/schema/appoinment.schema";
import { Patient, PatientDocument } from "./patient.schema";
@Injectable()
export class PatientService {

    constructor(
        @InjectModel(Doctor.name) private readonly doctorModel: Model<DoctorDocument>,
        @InjectModel(slot.name) private readonly slotModel: Model<SlotDocument>,
        @InjectModel(appoinment.name) private readonly appointmentModel: Model<appoinmentDocument>,
    @InjectModel(Patient.name) private readonly patientModel: Model<PatientDocument>
    ) { }

    async getAllDoctors() {
        try {
            const doctors = await this.doctorModel.find({}, 'name email specialization').exec();
            return doctors;
        } catch (error) {
            throw new Error('Failed to fetch doctors');
        }
    }

    async getAvailableSlotsForDoctor(doctorId: string) {
        try {
            const slots = await this.slotModel.find({ doctorId: doctorId, status: 'available', }).exec();

            if (!slots) {
                throw new Error('Doctor not found');
            }
            // Assuming slots are stored in the doctor schema, adjust as necessary
            return slots;
        }
        catch (error) {
            throw new Error('Failed to fetch slots for doctor');
        }
    }
    async bookAppointment(slotId: string, patientId: string) {
        try {
            // Check if the slot is available

            console.log('Slot ID:', slotId);
            console.log('Patient ID:', patientId); 

            const slot = await this.slotModel.findById(slotId).exec();
            if (!slot || slot.status !== 'available') {
                throw new Error('Slot not available');
            }
            console.log("slot done");
            const patient = await this.patientModel.findById(patientId).exec();
            if(!patient){
                throw new Error('Patient not found');
            }
            console.log("slot done");
            // Create a new appointment
            const appointment = new this.appointmentModel({
                doctorId: slot.doctorId,
                patientId: patientId,
                slotId: slotId,
            });
            console.log("slot done");
            slot.status = 'booked';
            await slot.save();

            await appointment.save();
            // Update the slot status to booked
           const doctor= await this.doctorModel.findById(slot.doctorId).exec();
            if (!doctor) {
                throw new Error('Doctor not found');
            }
            return { 
                message: 'Appointment booked successfully',
                appoinment: {
                    Doctor_name : doctor.name,
                    Doctor_specialization: doctor.specialization,
                    patientName: patient.name,
                    patientEmail: patient.email,
                    From_time: slot.from,
                    To_time: slot.to
                }

            };
        } catch (error) {
            throw new Error('Failed to book appointment: ' + error.message);
        }
    }
}