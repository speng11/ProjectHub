class ChangePasswordValidation < ActiveModel::Validator
    def validate(record)
        
        user_login = UserLogin.where('token = (?)', record.token).take
        current_user = User.where(:email => user_login.email).take

        require 'digest'
        md5 = Digest::MD5.new
        old_password = md5.hexdigest record.current_password
        
        if current_user.password != old_password
            record.errors[:base] << "Current password is incorrect."
        end

        if record.new_password != record.confirm_password
            record.errors[:base] << "Your passwords do not match."
        end

        if record.confirm_password =~ /\d/         # Calling String's =~ method.
            # valid contains number
        else
            record.errors[:base] << "Your password must contain at least 1 number."
        end

        if record.confirm_password =~ /[A-Z]/
            # valid contains upper case
        else
            record.errors[:base] << "Your password must contain at least 1 capital."
        end

        if record.confirm_password.length <= 5
            record.errors[:base] << "Your password is not long enough."
        end
        
        #password = md5.hexdigest record.password
        #user = User.where('email = (?) AND password =  (?)', record.email, password).take
        #if user == nil
        #record.errors[:base] << "Invalid Credentials"
        #end
    end
end

class ChangePassword < ActiveRecord::Base
    attr_accessor :token
    validates_with ChangePasswordValidation
end
